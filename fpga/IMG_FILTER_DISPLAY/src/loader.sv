module loader #(
    parameter DATA_WIDTH = 8,
    parameter FILTER_SIZE = 3
) 
(
    // System Inputs
    input  wire        clk,
    input  wire        rst_n,      // Active low system reset
    input  wire        i_vsync,    // Active low Vertical Sync (Frame Reset)
    
    // User interface
    input  wire        i_next,     // Request next data (read enable)
    output wire [7:0]  o_data,     // Data output (8-bit grayscale)
    output wire        o_valid     // Data is valid (FIFO not empty)
);

    //-----------------------------------------------------
    // Parameters
    //-----------------------------------------------------
    localparam MAX_ADDR       = 16'hFFFF;        // 16-bit address depth (65536)
    localparam START_ADDR     = 16'd14;          // Skip first 10 pixels due to bootrom latency
    localparam IMG_W          = 225;

    //-----------------------------------------------------
    // Internal Signals
    //-----------------------------------------------------
    // PROM Signals
    wire [7:0]  prom_dout;
    reg  [15:0] prom_addr;
    wire        prom_ce;
    // reg         prom_valid_q; 
    // reg         prom_valid_q2;
    
    // Filter Mode Signals
    // logic [DATA_WIDTH-1:0] line_buffs [FILTER_SIZE-1][IMG_W]; // REMOVED as per request
    logic [DATA_WIDTH-1:0] window [FILTER_SIZE][FILTER_SIZE]; // KxK Window
    // logic [7:0] lb_wr_ptr;    // Line Buffer Write Pointer
    
    // reg   [7:0] filter_row_cnt;
    // logic       filter_priming_done;
    
    //-----------------------------------------------------
    // 1. PROM Control Logic (Filter Mode Only)
    //-----------------------------------------------------
    
    // Read if we need to prime (fill buffers) OR if Display Requests (i_next).
    // Stops reading if we reach the end of the image.
    // Read if we need to prime (fill buffers) OR if Display Requests (i_next).
    // Stops reading if we reach the end of the image.
    // assign prom_ce = (!filter_priming_done || i_next) && (prom_addr < 16'd50624);
    reg prom_ce_reg;
    assign prom_ce = prom_ce_reg;

    //-----------------------------------------------------
    // 3. Kernel Loader State Machine (Replaces Line Buffers)
    //-----------------------------------------------------
    
    // State definitions
    typedef enum logic [2:0] {
        ST_RESET,
        ST_IDLE,
        ST_SET_ADDR,
        ST_WAIT_DATA,
        ST_STORE_DATA,
        ST_FIRE_FILTER,
        ST_NEXT_WIN
    } state_t;
    
    state_t state;
    
    reg [7:0] k_r; // Kernel Row Iterator
    reg [7:0] k_c; // Kernel Col Iterator
    reg [7:0] img_x; // Current Window Top-Left X
    reg [7:0] img_y; // Current Window Top-Left Y
    
    reg filter_valid_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= ST_RESET;
            prom_addr       <= START_ADDR;
            prom_ce_reg     <= 1'b0;
            k_r             <= 0;
            k_c             <= 0;
            img_x           <= 0;
            img_y           <= 0;
            filter_valid_in <= 1'b0;
            
            // Clear Window
            for(int r=0; r<FILTER_SIZE; r++)
                for(int c=0; c<FILTER_SIZE; c++)
                    window[r][c] <= 0;
                    
        end else begin
            if (!i_vsync) begin
                state           <= ST_RESET;
            end else begin
                case (state)
                    ST_RESET: begin
                        img_x <= 0;
                        img_y <= 0;
                        k_r   <= 0;
                        k_c   <= 0;
                        state <= ST_IDLE;
                    end
                    
                    ST_IDLE: begin
                        // Wait for request or free run?
                        // Assuming free run to fill valid data for display
                        // or check i_next if strictly demanded.
                        // Given the slowness, we better start immediately.
                        state <= ST_SET_ADDR;
                        k_r   <= 0;
                        k_c   <= 0;
                    end
                    
                    ST_SET_ADDR: begin
                        // Calculate Address: Start + (y+kr)*W + (x+kc)
                        // Logic: "increase from start_addr + k ... + img_width"
                        prom_addr   <= START_ADDR + (img_y + k_r) * IMG_W + (img_x + k_c);
                        prom_ce_reg <= 1'b1;
                        state       <= ST_WAIT_DATA;
                    end
                    
                    ST_WAIT_DATA: begin
                        // Wait for ROM latency (assuming 1 cycle after addr set?)
                        // If Gowin PROM is Block RAM, it needs clock edge.
                        // We set addr in previous clock.
                        // Data should be ready on next edge if latency is 1.
                        // Or we wait 1 cycle here to be safe if latency is 2.
                        // Let's assume we capture in next state.
                        prom_ce_reg <= 1'b0; // Pulse CE
                        state       <= ST_STORE_DATA;
                    end
                    
                    ST_STORE_DATA: begin
                        // Capture Data
                        window[k_r][k_c] <= prom_dout;
                        
                        // Increment Kernel Iterators
                        if (k_c == FILTER_SIZE - 1) begin
                            k_c <= 0;
                            if (k_r == FILTER_SIZE - 1) begin
                                k_r <= 0;
                                state <= ST_FIRE_FILTER; // Full kernel loaded
                            end else begin
                                k_r <= k_r + 1'b1; // Jump a line logic
                                state <= ST_SET_ADDR;
                            end
                        end else begin
                            k_c <= k_c + 1'b1; // Next pixel in row
                            state <= ST_SET_ADDR;
                        end
                    end
                    
                    ST_FIRE_FILTER: begin
                        // Assert valid for inputs
                        filter_valid_in <= 1'b1; 
                        state <= ST_NEXT_WIN;
                    end
                    
                    ST_NEXT_WIN: begin
                        filter_valid_in <= 1'b0;
                        
                        // Move Image Window
                        if (img_x == IMG_W - 1) begin 
                            // End of line? 
                            // Note: We might want to stop if K doesn't fit?
                            // But usually we iterate full image.
                            img_x <= 0;
                            if (img_y == IMG_W - 1) begin // Assuming Square Img
                                state <= ST_IDLE; // Frame Done
                            end else begin
                                img_y <= img_y + 1'b1;
                                state <= ST_SET_ADDR;
                            end
                        end else begin
                            img_x <= img_x + 1'b1;
                            state <= ST_SET_ADDR;
                        end
                    end
                endcase
            end
        end
    end
    
    // Filter Instantiation
    GAUS_BLUR_FILTER #(
        .K(FILTER_SIZE),
        .DATA_W(DATA_WIDTH)
    ) u_gaus_blur_filter (
        .clk(clk),
        .rst_n(rst_n),
        // Valid when our FSM says so
        .i_valid(filter_valid_in), 
        .window(window),
        .o_valid(o_valid),
        .pixel_out(o_data)
    );


    Gowin_pROM u_gowin_prom (
        .clk(clk),
        .reset(!rst_n),
        .oce(prom_ce_reg),
        .ce(prom_ce_reg),
        .ad(prom_addr),
        .dout(prom_dout)
    );
    
    // NOTE: GAUS_BLUR_FILTER output port name check:
    // User file: output logic [DATA_W-1:0] pixel_out
    // I should check if I need to change o_data port mapping.
    // Wait, let me check the GAUS_BLUR_FILTER definition in my context.
    
endmodule
