module gw_gao(
    tp0_vs_in,
    tp0_hs_in,
    tp0_de_in,
    \u_loader/o_valid ,
    \u_loader/prom_ce ,
    \u_loader/prom_dout[7] ,
    \u_loader/prom_dout[6] ,
    \u_loader/prom_dout[5] ,
    \u_loader/prom_dout[4] ,
    \u_loader/prom_dout[3] ,
    \u_loader/prom_dout[2] ,
    \u_loader/prom_dout[1] ,
    \u_loader/prom_dout[0] ,
    \u_loader/prom_valid_q ,
    \u_loader/prom_addr[7] ,
    \u_loader/prom_addr[6] ,
    \u_loader/prom_addr[5] ,
    \u_loader/prom_addr[4] ,
    \u_loader/prom_addr[3] ,
    \u_loader/prom_addr[2] ,
    \u_loader/prom_addr[1] ,
    \u_loader/prom_addr[0] ,
    \u_loader/fifo_wr ,
    \u_loader/fifo_empty ,
    \u_loader/i_next ,
    \cnt_hor[12] ,
    \cnt_hor[11] ,
    \cnt_hor[10] ,
    \cnt_hor[9] ,
    \cnt_hor[8] ,
    \cnt_hor[7] ,
    \cnt_hor[6] ,
    \cnt_hor[5] ,
    \cnt_hor[4] ,
    \cnt_hor[3] ,
    \cnt_hor[2] ,
    \cnt_hor[1] ,
    \cnt_hor[0] ,
    \cnt_ver[12] ,
    \cnt_ver[11] ,
    \cnt_ver[10] ,
    \cnt_ver[9] ,
    \cnt_ver[8] ,
    \cnt_ver[7] ,
    \cnt_ver[6] ,
    \cnt_ver[5] ,
    \cnt_ver[4] ,
    \cnt_ver[3] ,
    \cnt_ver[2] ,
    \cnt_ver[1] ,
    \cnt_ver[0] ,
    \run_cnt[24] ,
    rst_n,
    pix_clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input tp0_vs_in;
input tp0_hs_in;
input tp0_de_in;
input \u_loader/o_valid ;
input \u_loader/prom_ce ;
input \u_loader/prom_dout[7] ;
input \u_loader/prom_dout[6] ;
input \u_loader/prom_dout[5] ;
input \u_loader/prom_dout[4] ;
input \u_loader/prom_dout[3] ;
input \u_loader/prom_dout[2] ;
input \u_loader/prom_dout[1] ;
input \u_loader/prom_dout[0] ;
input \u_loader/prom_valid_q ;
input \u_loader/prom_addr[7] ;
input \u_loader/prom_addr[6] ;
input \u_loader/prom_addr[5] ;
input \u_loader/prom_addr[4] ;
input \u_loader/prom_addr[3] ;
input \u_loader/prom_addr[2] ;
input \u_loader/prom_addr[1] ;
input \u_loader/prom_addr[0] ;
input \u_loader/fifo_wr ;
input \u_loader/fifo_empty ;
input \u_loader/i_next ;
input \cnt_hor[12] ;
input \cnt_hor[11] ;
input \cnt_hor[10] ;
input \cnt_hor[9] ;
input \cnt_hor[8] ;
input \cnt_hor[7] ;
input \cnt_hor[6] ;
input \cnt_hor[5] ;
input \cnt_hor[4] ;
input \cnt_hor[3] ;
input \cnt_hor[2] ;
input \cnt_hor[1] ;
input \cnt_hor[0] ;
input \cnt_ver[12] ;
input \cnt_ver[11] ;
input \cnt_ver[10] ;
input \cnt_ver[9] ;
input \cnt_ver[8] ;
input \cnt_ver[7] ;
input \cnt_ver[6] ;
input \cnt_ver[5] ;
input \cnt_ver[4] ;
input \cnt_ver[3] ;
input \cnt_ver[2] ;
input \cnt_ver[1] ;
input \cnt_ver[0] ;
input \run_cnt[24] ;
input rst_n;
input pix_clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire tp0_vs_in;
wire tp0_hs_in;
wire tp0_de_in;
wire \u_loader/o_valid ;
wire \u_loader/prom_ce ;
wire \u_loader/prom_dout[7] ;
wire \u_loader/prom_dout[6] ;
wire \u_loader/prom_dout[5] ;
wire \u_loader/prom_dout[4] ;
wire \u_loader/prom_dout[3] ;
wire \u_loader/prom_dout[2] ;
wire \u_loader/prom_dout[1] ;
wire \u_loader/prom_dout[0] ;
wire \u_loader/prom_valid_q ;
wire \u_loader/prom_addr[7] ;
wire \u_loader/prom_addr[6] ;
wire \u_loader/prom_addr[5] ;
wire \u_loader/prom_addr[4] ;
wire \u_loader/prom_addr[3] ;
wire \u_loader/prom_addr[2] ;
wire \u_loader/prom_addr[1] ;
wire \u_loader/prom_addr[0] ;
wire \u_loader/fifo_wr ;
wire \u_loader/fifo_empty ;
wire \u_loader/i_next ;
wire \cnt_hor[12] ;
wire \cnt_hor[11] ;
wire \cnt_hor[10] ;
wire \cnt_hor[9] ;
wire \cnt_hor[8] ;
wire \cnt_hor[7] ;
wire \cnt_hor[6] ;
wire \cnt_hor[5] ;
wire \cnt_hor[4] ;
wire \cnt_hor[3] ;
wire \cnt_hor[2] ;
wire \cnt_hor[1] ;
wire \cnt_hor[0] ;
wire \cnt_ver[12] ;
wire \cnt_ver[11] ;
wire \cnt_ver[10] ;
wire \cnt_ver[9] ;
wire \cnt_ver[8] ;
wire \cnt_ver[7] ;
wire \cnt_ver[6] ;
wire \cnt_ver[5] ;
wire \cnt_ver[4] ;
wire \cnt_ver[3] ;
wire \cnt_ver[2] ;
wire \cnt_ver[1] ;
wire \cnt_ver[0] ;
wire \run_cnt[24] ;
wire rst_n;
wire pix_clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(\run_cnt[24] ),
    .trig1_i(rst_n),
    .data_i({tp0_vs_in,tp0_hs_in,tp0_de_in,\u_loader/o_valid ,\u_loader/prom_ce ,\u_loader/prom_dout[7] ,\u_loader/prom_dout[6] ,\u_loader/prom_dout[5] ,\u_loader/prom_dout[4] ,\u_loader/prom_dout[3] ,\u_loader/prom_dout[2] ,\u_loader/prom_dout[1] ,\u_loader/prom_dout[0] ,\u_loader/prom_valid_q ,\u_loader/prom_addr[7] ,\u_loader/prom_addr[6] ,\u_loader/prom_addr[5] ,\u_loader/prom_addr[4] ,\u_loader/prom_addr[3] ,\u_loader/prom_addr[2] ,\u_loader/prom_addr[1] ,\u_loader/prom_addr[0] ,\u_loader/fifo_wr ,\u_loader/fifo_empty ,\u_loader/i_next ,\cnt_hor[12] ,\cnt_hor[11] ,\cnt_hor[10] ,\cnt_hor[9] ,\cnt_hor[8] ,\cnt_hor[7] ,\cnt_hor[6] ,\cnt_hor[5] ,\cnt_hor[4] ,\cnt_hor[3] ,\cnt_hor[2] ,\cnt_hor[1] ,\cnt_hor[0] ,\cnt_ver[12] ,\cnt_ver[11] ,\cnt_ver[10] ,\cnt_ver[9] ,\cnt_ver[8] ,\cnt_ver[7] ,\cnt_ver[6] ,\cnt_ver[5] ,\cnt_ver[4] ,\cnt_ver[3] ,\cnt_ver[2] ,\cnt_ver[1] ,\cnt_ver[0] }),
    .clk_i(pix_clk)
);

endmodule
