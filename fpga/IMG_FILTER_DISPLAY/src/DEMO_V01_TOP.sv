module DEMO_V01_TOP #(
)
(
    input clk_i,
    input rst_n,
    output     [4:0]  O_led           , 
    output            O_tmds_clk_p    ,
    output            O_tmds_clk_n    ,
    output     [2:0]  O_tmds_data_p   ,//{r,g,b}
    output     [2:0]  O_tmds_data_n   
);

//--------------------------
wire        tp0_vs_in  ;
wire        tp0_hs_in  ;
wire        tp0_de_in ;
wire [ 7:0] tp0_data_r/*synthesis syn_keep=1*/;
wire [ 7:0] tp0_data_g/*synthesis syn_keep=1*/;
wire [ 7:0] tp0_data_b/*synthesis syn_keep=1*/;

reg         vs_r;
reg  [11:0]  cnt_vs;

//------------------------------------



//------------------------------------
//counting for running led blinking
reg  [31:0] run_cnt;
wire        running;
always @(posedge clk_i or negedge rst_n) begin
        if(!rst_n)
            run_cnt <= 32'd0;
        else if(run_cnt >= 32'd27_000_000)
            run_cnt <= 32'd0;
        else
            run_cnt <= run_cnt + 1'b1;
end
assign  running = (run_cnt < 32'd14_000_000) ? 1'b1 : 1'b0;
assign  O_led[0] = running;
assign  O_led[1] = running;
assign  O_led[4] = running;
//------------------------------------

//reset case
assign  O_led[2] = ~rst_n;
assign  O_led[3] = ~rst_n;

//HDMI4 TX
wire serial_clk;
wire pll_lock;

wire hdmi4_rst_n;

wire pix_clk;

// 4.5 MHz
// planned to be system frequency
//Gowin_rPLL u_PLL_1(
//.clkin     (clk_i     ),    //input clk 
//.clkout    (sys_clk)   //output clk 
//);

//25.2MHZ
Gowin_rPLL_21 u_PLL_3(
.clkin     (serial_clk     ),    //input clk 
.clkout    (sys_clk)   //output clk 
);

//371.25MHz
tmds_rPLL u_PLL_2 (
.clkin     (clk_i     ),    //input clk 
.clkout    (serial_clk),   //output clk 
.lock      (pll_lock  )     //output lock
);

//25.169MHZ ---> 59.92Hz not ideal but okay
CLKDIV u_CLKDIV (
.RESETN(hdmi4_rst_n),
.HCLKIN(serial_clk), //clk  x5
.CLKOUT(pix_clk),    //clk  x1
.CALIB (1'b1)
);



logic data_request;
logic data_valid;
logic [7:0] data_out;
logic [7:0] data_out_controlled;

assign data_out_controlled = data_request ? data_out : 8'b0;

    loader u_loader (
        .clk(sys_clk),
        .rst_n(hdmi4_rst_n),
        .i_vsync(tp0_vs_in),
        .i_next(data_request),
        .o_data(data_out),
        .o_valid(data_valid)
    );


//----------------------------------------------------
localparam H_ACTIVE    = 1280;
localparam H_TOTAL     = 1650; // 1280 + 110 (FP) + 40 (Sync) + 220 (BP)
localparam V_ACTIVE    = 720;
localparam V_TOTAL     = 750;  // 720 + 5 (FP) + 5 (Sync) + 20 (BP)
logic [11:0]cnt_hor;
logic [11:0]cnt_ver;

//counter for 225 horizontal
always @(posedge sys_clk or negedge hdmi4_rst_n) begin
    if(!hdmi4_rst_n)
        cnt_hor <= H_ACTIVE;
    else if(cnt_hor == H_TOTAL - 1) // Reset at end of line
        cnt_hor <= 12'd0;
    else
        cnt_hor <= cnt_hor + 1'b1;
end

//counter for 225 vertical
always @(posedge sys_clk or negedge hdmi4_rst_n) begin
    if(!hdmi4_rst_n)
        cnt_ver <= V_ACTIVE;
    else if(cnt_hor == H_TOTAL - 1) begin // Tick ONLY at end of line
        if(cnt_ver == V_TOTAL - 1)        // Reset at end of frame
            cnt_ver <= 12'd0;
        else
            cnt_ver <= cnt_ver + 1'b1;
    end
end

    // 3. Signals
    // Data Enable: High only inside the active box
    assign tp0_de_in = (cnt_hor < H_ACTIVE) && (cnt_ver < V_ACTIVE);
    // Syncs: Usually active low pulses somewhere in the blanking area
// (Simplified example)
    assign tp0_hs_in = (cnt_hor >= H_ACTIVE + 110 && cnt_hor < H_ACTIVE + 110 + 40) ? 1'b1 : 1'b0; 
    assign tp0_vs_in = (cnt_ver >= V_ACTIVE + 5   && cnt_ver < V_ACTIVE + 5 + 5)    ? 1'b1 : 1'b0;

// Request data when we are inside the 225x225 image area
// Image shifted to (50, 50)
localparam IMG_START_X = 12'd50;
localparam IMG_START_Y = 12'd50;
assign data_request = (cnt_hor >= IMG_START_X && cnt_hor < IMG_START_X + 225) && 
                      (cnt_ver >= IMG_START_Y && cnt_ver < IMG_START_Y + 225);

//----------------------------------------------------




assign hdmi4_rst_n = rst_n & pll_lock;



DVI_TX_Top u_DVI_TX_Top
(
    .I_rst_n       (hdmi4_rst_n   ),  //asynchronous reset, low active
    .I_serial_clk  (serial_clk    ),
    .I_rgb_clk     (pix_clk       ),  //pixel clock

    .I_rgb_vs      (tp0_vs_in     ), 
    .I_rgb_hs      (tp0_hs_in     ),    
    .I_rgb_de      (tp0_de_in     ), 

    .I_rgb_r       (  data_out_controlled ),  //tp0_data_r
    .I_rgb_g       (  data_out_controlled ),  
    .I_rgb_b       (  data_out_controlled ),  

    .O_tmds_clk_p  (O_tmds_clk_p  ),
    .O_tmds_clk_n  (O_tmds_clk_n  ),
    .O_tmds_data_p (O_tmds_data_p ),  //{r,g,b}
    .O_tmds_data_n (O_tmds_data_n )
);





endmodule
