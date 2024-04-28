// ==============================================================
// File generated on Sun Apr 28 14:40:29 +0800 2024
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
// SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
// IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1ns/1ps
module Conv_AXILiteS_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 11,
    C_S_AXI_DATA_WIDTH = 32
)(
    // axi4 lite slave signals
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire                          interrupt,
    // user signals
    output wire                          ap_start,
    input  wire                          ap_done,
    input  wire                          ap_ready,
    input  wire                          ap_idle,
    output wire [15:0]                   CHin_V,
    output wire [15:0]                   Hin_V,
    output wire [15:0]                   Win_V,
    output wire [15:0]                   CHout_V,
    output wire [7:0]                    Kx_V,
    output wire [7:0]                    Ky_V,
    output wire [7:0]                    Sx_V,
    output wire [7:0]                    Sy_V,
    output wire [0:0]                    mode_V,
    output wire [0:0]                    relu_en_V,
    input  wire [6:0]                    feature_in_address0,
    input  wire                          feature_in_ce0,
    output wire [15:0]                   feature_in_q0,
    input  wire [3:0]                    W_address0,
    input  wire                          W_ce0,
    output wire [15:0]                   W_q0,
    input  wire [6:0]                    bias_address0,
    input  wire                          bias_ce0,
    output wire [15:0]                   bias_q0,
    input  wire [6:0]                    feature_out_address0,
    input  wire                          feature_out_ce0,
    input  wire                          feature_out_we0,
    input  wire [15:0]                   feature_out_d0
);
//------------------------Address Info-------------------
// 0x000 : Control signals
//         bit 0  - ap_start (Read/Write/COH)
//         bit 1  - ap_done (Read/COR)
//         bit 2  - ap_idle (Read)
//         bit 3  - ap_ready (Read)
//         bit 7  - auto_restart (Read/Write)
//         others - reserved
// 0x004 : Global Interrupt Enable Register
//         bit 0  - Global Interrupt Enable (Read/Write)
//         others - reserved
// 0x008 : IP Interrupt Enable Register (Read/Write)
//         bit 0  - Channel 0 (ap_done)
//         bit 1  - Channel 1 (ap_ready)
//         others - reserved
// 0x00c : IP Interrupt Status Register (Read/TOW)
//         bit 0  - Channel 0 (ap_done)
//         bit 1  - Channel 1 (ap_ready)
//         others - reserved
// 0x010 : Data signal of CHin_V
//         bit 15~0 - CHin_V[15:0] (Read/Write)
//         others   - reserved
// 0x014 : reserved
// 0x018 : Data signal of Hin_V
//         bit 15~0 - Hin_V[15:0] (Read/Write)
//         others   - reserved
// 0x01c : reserved
// 0x020 : Data signal of Win_V
//         bit 15~0 - Win_V[15:0] (Read/Write)
//         others   - reserved
// 0x024 : reserved
// 0x028 : Data signal of CHout_V
//         bit 15~0 - CHout_V[15:0] (Read/Write)
//         others   - reserved
// 0x02c : reserved
// 0x030 : Data signal of Kx_V
//         bit 7~0 - Kx_V[7:0] (Read/Write)
//         others  - reserved
// 0x034 : reserved
// 0x038 : Data signal of Ky_V
//         bit 7~0 - Ky_V[7:0] (Read/Write)
//         others  - reserved
// 0x03c : reserved
// 0x040 : Data signal of Sx_V
//         bit 7~0 - Sx_V[7:0] (Read/Write)
//         others  - reserved
// 0x044 : reserved
// 0x048 : Data signal of Sy_V
//         bit 7~0 - Sy_V[7:0] (Read/Write)
//         others  - reserved
// 0x04c : reserved
// 0x050 : Data signal of mode_V
//         bit 0  - mode_V[0] (Read/Write)
//         others - reserved
// 0x054 : reserved
// 0x058 : Data signal of relu_en_V
//         bit 0  - relu_en_V[0] (Read/Write)
//         others - reserved
// 0x05c : reserved
// 0x100 ~
// 0x1ff : Memory 'feature_in' (100 * 16b)
//         Word n : bit [15: 0] - feature_in[2n]
//                  bit [31:16] - feature_in[2n+1]
// 0x200 ~
// 0x21f : Memory 'W' (9 * 16b)
//         Word n : bit [15: 0] - W[2n]
//                  bit [31:16] - W[2n+1]
// 0x300 ~
// 0x3ff : Memory 'bias' (100 * 16b)
//         Word n : bit [15: 0] - bias[2n]
//                  bit [31:16] - bias[2n+1]
// 0x400 ~
// 0x4ff : Memory 'feature_out' (100 * 16b)
//         Word n : bit [15: 0] - feature_out[2n]
//                  bit [31:16] - feature_out[2n+1]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_AP_CTRL          = 11'h000,
    ADDR_GIE              = 11'h004,
    ADDR_IER              = 11'h008,
    ADDR_ISR              = 11'h00c,
    ADDR_CHIN_V_DATA_0    = 11'h010,
    ADDR_CHIN_V_CTRL      = 11'h014,
    ADDR_HIN_V_DATA_0     = 11'h018,
    ADDR_HIN_V_CTRL       = 11'h01c,
    ADDR_WIN_V_DATA_0     = 11'h020,
    ADDR_WIN_V_CTRL       = 11'h024,
    ADDR_CHOUT_V_DATA_0   = 11'h028,
    ADDR_CHOUT_V_CTRL     = 11'h02c,
    ADDR_KX_V_DATA_0      = 11'h030,
    ADDR_KX_V_CTRL        = 11'h034,
    ADDR_KY_V_DATA_0      = 11'h038,
    ADDR_KY_V_CTRL        = 11'h03c,
    ADDR_SX_V_DATA_0      = 11'h040,
    ADDR_SX_V_CTRL        = 11'h044,
    ADDR_SY_V_DATA_0      = 11'h048,
    ADDR_SY_V_CTRL        = 11'h04c,
    ADDR_MODE_V_DATA_0    = 11'h050,
    ADDR_MODE_V_CTRL      = 11'h054,
    ADDR_RELU_EN_V_DATA_0 = 11'h058,
    ADDR_RELU_EN_V_CTRL   = 11'h05c,
    ADDR_FEATURE_IN_BASE  = 11'h100,
    ADDR_FEATURE_IN_HIGH  = 11'h1ff,
    ADDR_W_BASE           = 11'h200,
    ADDR_W_HIGH           = 11'h21f,
    ADDR_BIAS_BASE        = 11'h300,
    ADDR_BIAS_HIGH        = 11'h3ff,
    ADDR_FEATURE_OUT_BASE = 11'h400,
    ADDR_FEATURE_OUT_HIGH = 11'h4ff,
    WRIDLE                = 2'd0,
    WRDATA                = 2'd1,
    WRRESP                = 2'd2,
    WRRESET               = 2'd3,
    RDIDLE                = 2'd0,
    RDDATA                = 2'd1,
    RDRESET               = 2'd2,
    ADDR_BITS         = 11;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [31:0]                   wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [31:0]                   rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    reg                           int_ap_idle;
    reg                           int_ap_ready;
    reg                           int_ap_done = 1'b0;
    reg                           int_ap_start = 1'b0;
    reg                           int_auto_restart = 1'b0;
    reg                           int_gie = 1'b0;
    reg  [1:0]                    int_ier = 2'b0;
    reg  [1:0]                    int_isr = 2'b0;
    reg  [15:0]                   int_CHin_V = 'b0;
    reg  [15:0]                   int_Hin_V = 'b0;
    reg  [15:0]                   int_Win_V = 'b0;
    reg  [15:0]                   int_CHout_V = 'b0;
    reg  [7:0]                    int_Kx_V = 'b0;
    reg  [7:0]                    int_Ky_V = 'b0;
    reg  [7:0]                    int_Sx_V = 'b0;
    reg  [7:0]                    int_Sy_V = 'b0;
    reg  [0:0]                    int_mode_V = 'b0;
    reg  [0:0]                    int_relu_en_V = 'b0;
    // memory signals
    wire [5:0]                    int_feature_in_address0;
    wire                          int_feature_in_ce0;
    wire                          int_feature_in_we0;
    wire [3:0]                    int_feature_in_be0;
    wire [31:0]                   int_feature_in_d0;
    wire [31:0]                   int_feature_in_q0;
    wire [5:0]                    int_feature_in_address1;
    wire                          int_feature_in_ce1;
    wire                          int_feature_in_we1;
    wire [3:0]                    int_feature_in_be1;
    wire [31:0]                   int_feature_in_d1;
    wire [31:0]                   int_feature_in_q1;
    reg                           int_feature_in_read;
    reg                           int_feature_in_write;
    reg  [0:0]                    int_feature_in_shift;
    wire [2:0]                    int_W_address0;
    wire                          int_W_ce0;
    wire                          int_W_we0;
    wire [3:0]                    int_W_be0;
    wire [31:0]                   int_W_d0;
    wire [31:0]                   int_W_q0;
    wire [2:0]                    int_W_address1;
    wire                          int_W_ce1;
    wire                          int_W_we1;
    wire [3:0]                    int_W_be1;
    wire [31:0]                   int_W_d1;
    wire [31:0]                   int_W_q1;
    reg                           int_W_read;
    reg                           int_W_write;
    reg  [0:0]                    int_W_shift;
    wire [5:0]                    int_bias_address0;
    wire                          int_bias_ce0;
    wire                          int_bias_we0;
    wire [3:0]                    int_bias_be0;
    wire [31:0]                   int_bias_d0;
    wire [31:0]                   int_bias_q0;
    wire [5:0]                    int_bias_address1;
    wire                          int_bias_ce1;
    wire                          int_bias_we1;
    wire [3:0]                    int_bias_be1;
    wire [31:0]                   int_bias_d1;
    wire [31:0]                   int_bias_q1;
    reg                           int_bias_read;
    reg                           int_bias_write;
    reg  [0:0]                    int_bias_shift;
    wire [5:0]                    int_feature_out_address0;
    wire                          int_feature_out_ce0;
    wire                          int_feature_out_we0;
    wire [3:0]                    int_feature_out_be0;
    wire [31:0]                   int_feature_out_d0;
    wire [31:0]                   int_feature_out_q0;
    wire [5:0]                    int_feature_out_address1;
    wire                          int_feature_out_ce1;
    wire                          int_feature_out_we1;
    wire [3:0]                    int_feature_out_be1;
    wire [31:0]                   int_feature_out_d1;
    wire [31:0]                   int_feature_out_q1;
    reg                           int_feature_out_read;
    reg                           int_feature_out_write;
    reg  [0:0]                    int_feature_out_shift;

//------------------------Instantiation------------------
// int_feature_in
Conv_AXILiteS_s_axi_ram #(
    .BYTES    ( 4 ),
    .DEPTH    ( 50 )
) int_feature_in (
    .clk0     ( ACLK ),
    .address0 ( int_feature_in_address0 ),
    .ce0      ( int_feature_in_ce0 ),
    .we0      ( int_feature_in_we0 ),
    .be0      ( int_feature_in_be0 ),
    .d0       ( int_feature_in_d0 ),
    .q0       ( int_feature_in_q0 ),
    .clk1     ( ACLK ),
    .address1 ( int_feature_in_address1 ),
    .ce1      ( int_feature_in_ce1 ),
    .we1      ( int_feature_in_we1 ),
    .be1      ( int_feature_in_be1 ),
    .d1       ( int_feature_in_d1 ),
    .q1       ( int_feature_in_q1 )
);
// int_W
Conv_AXILiteS_s_axi_ram #(
    .BYTES    ( 4 ),
    .DEPTH    ( 5 )
) int_W (
    .clk0     ( ACLK ),
    .address0 ( int_W_address0 ),
    .ce0      ( int_W_ce0 ),
    .we0      ( int_W_we0 ),
    .be0      ( int_W_be0 ),
    .d0       ( int_W_d0 ),
    .q0       ( int_W_q0 ),
    .clk1     ( ACLK ),
    .address1 ( int_W_address1 ),
    .ce1      ( int_W_ce1 ),
    .we1      ( int_W_we1 ),
    .be1      ( int_W_be1 ),
    .d1       ( int_W_d1 ),
    .q1       ( int_W_q1 )
);
// int_bias
Conv_AXILiteS_s_axi_ram #(
    .BYTES    ( 4 ),
    .DEPTH    ( 50 )
) int_bias (
    .clk0     ( ACLK ),
    .address0 ( int_bias_address0 ),
    .ce0      ( int_bias_ce0 ),
    .we0      ( int_bias_we0 ),
    .be0      ( int_bias_be0 ),
    .d0       ( int_bias_d0 ),
    .q0       ( int_bias_q0 ),
    .clk1     ( ACLK ),
    .address1 ( int_bias_address1 ),
    .ce1      ( int_bias_ce1 ),
    .we1      ( int_bias_we1 ),
    .be1      ( int_bias_be1 ),
    .d1       ( int_bias_d1 ),
    .q1       ( int_bias_q1 )
);
// int_feature_out
Conv_AXILiteS_s_axi_ram #(
    .BYTES    ( 4 ),
    .DEPTH    ( 50 )
) int_feature_out (
    .clk0     ( ACLK ),
    .address0 ( int_feature_out_address0 ),
    .ce0      ( int_feature_out_ce0 ),
    .we0      ( int_feature_out_we0 ),
    .be0      ( int_feature_out_be0 ),
    .d0       ( int_feature_out_d0 ),
    .q0       ( int_feature_out_q0 ),
    .clk1     ( ACLK ),
    .address1 ( int_feature_out_address1 ),
    .ce1      ( int_feature_out_ce1 ),
    .we1      ( int_feature_out_we1 ),
    .be1      ( int_feature_out_be1 ),
    .d1       ( int_feature_out_d1 ),
    .q1       ( int_feature_out_q1 )
);

//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= AWADDR[ADDR_BITS-1:0];
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA) & !int_feature_in_read & !int_W_read & !int_bias_read & !int_feature_out_read;
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 1'b0;
            case (raddr)
                ADDR_AP_CTRL: begin
                    rdata[0] <= int_ap_start;
                    rdata[1] <= int_ap_done;
                    rdata[2] <= int_ap_idle;
                    rdata[3] <= int_ap_ready;
                    rdata[7] <= int_auto_restart;
                end
                ADDR_GIE: begin
                    rdata <= int_gie;
                end
                ADDR_IER: begin
                    rdata <= int_ier;
                end
                ADDR_ISR: begin
                    rdata <= int_isr;
                end
                ADDR_CHIN_V_DATA_0: begin
                    rdata <= int_CHin_V[15:0];
                end
                ADDR_HIN_V_DATA_0: begin
                    rdata <= int_Hin_V[15:0];
                end
                ADDR_WIN_V_DATA_0: begin
                    rdata <= int_Win_V[15:0];
                end
                ADDR_CHOUT_V_DATA_0: begin
                    rdata <= int_CHout_V[15:0];
                end
                ADDR_KX_V_DATA_0: begin
                    rdata <= int_Kx_V[7:0];
                end
                ADDR_KY_V_DATA_0: begin
                    rdata <= int_Ky_V[7:0];
                end
                ADDR_SX_V_DATA_0: begin
                    rdata <= int_Sx_V[7:0];
                end
                ADDR_SY_V_DATA_0: begin
                    rdata <= int_Sy_V[7:0];
                end
                ADDR_MODE_V_DATA_0: begin
                    rdata <= int_mode_V[0:0];
                end
                ADDR_RELU_EN_V_DATA_0: begin
                    rdata <= int_relu_en_V[0:0];
                end
            endcase
        end
        else if (int_feature_in_read) begin
            rdata <= int_feature_in_q1;
        end
        else if (int_W_read) begin
            rdata <= int_W_q1;
        end
        else if (int_bias_read) begin
            rdata <= int_bias_q1;
        end
        else if (int_feature_out_read) begin
            rdata <= int_feature_out_q1;
        end
    end
end


//------------------------Register logic-----------------
assign interrupt = int_gie & (|int_isr);
assign ap_start  = int_ap_start;
assign CHin_V    = int_CHin_V;
assign Hin_V     = int_Hin_V;
assign Win_V     = int_Win_V;
assign CHout_V   = int_CHout_V;
assign Kx_V      = int_Kx_V;
assign Ky_V      = int_Ky_V;
assign Sx_V      = int_Sx_V;
assign Sy_V      = int_Sy_V;
assign mode_V    = int_mode_V;
assign relu_en_V = int_relu_en_V;
// int_ap_start
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_start <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
            int_ap_start <= 1'b1;
        else if (ap_ready)
            int_ap_start <= int_auto_restart; // clear on handshake/auto restart
    end
end

// int_ap_done
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_done <= 1'b0;
    else if (ACLK_EN) begin
        if (ap_done)
            int_ap_done <= 1'b1;
        else if (ar_hs && raddr == ADDR_AP_CTRL)
            int_ap_done <= 1'b0; // clear on read
    end
end

// int_ap_idle
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_idle <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_idle <= ap_idle;
    end
end

// int_ap_ready
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_ready <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_ready <= ap_ready;
    end
end

// int_auto_restart
always @(posedge ACLK) begin
    if (ARESET)
        int_auto_restart <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
            int_auto_restart <=  WDATA[7];
    end
end

// int_gie
always @(posedge ACLK) begin
    if (ARESET)
        int_gie <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_GIE && WSTRB[0])
            int_gie <= WDATA[0];
    end
end

// int_ier
always @(posedge ACLK) begin
    if (ARESET)
        int_ier <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IER && WSTRB[0])
            int_ier <= WDATA[1:0];
    end
end

// int_isr[0]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[0] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[0] & ap_done)
            int_isr[0] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[0] <= int_isr[0] ^ WDATA[0]; // toggle on write
    end
end

// int_isr[1]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[1] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[1] & ap_ready)
            int_isr[1] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[1] <= int_isr[1] ^ WDATA[1]; // toggle on write
    end
end

// int_CHin_V[15:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_CHin_V[15:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_CHIN_V_DATA_0)
            int_CHin_V[15:0] <= (WDATA[31:0] & wmask) | (int_CHin_V[15:0] & ~wmask);
    end
end

// int_Hin_V[15:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_Hin_V[15:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_HIN_V_DATA_0)
            int_Hin_V[15:0] <= (WDATA[31:0] & wmask) | (int_Hin_V[15:0] & ~wmask);
    end
end

// int_Win_V[15:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_Win_V[15:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WIN_V_DATA_0)
            int_Win_V[15:0] <= (WDATA[31:0] & wmask) | (int_Win_V[15:0] & ~wmask);
    end
end

// int_CHout_V[15:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_CHout_V[15:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_CHOUT_V_DATA_0)
            int_CHout_V[15:0] <= (WDATA[31:0] & wmask) | (int_CHout_V[15:0] & ~wmask);
    end
end

// int_Kx_V[7:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_Kx_V[7:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_KX_V_DATA_0)
            int_Kx_V[7:0] <= (WDATA[31:0] & wmask) | (int_Kx_V[7:0] & ~wmask);
    end
end

// int_Ky_V[7:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_Ky_V[7:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_KY_V_DATA_0)
            int_Ky_V[7:0] <= (WDATA[31:0] & wmask) | (int_Ky_V[7:0] & ~wmask);
    end
end

// int_Sx_V[7:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_Sx_V[7:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_SX_V_DATA_0)
            int_Sx_V[7:0] <= (WDATA[31:0] & wmask) | (int_Sx_V[7:0] & ~wmask);
    end
end

// int_Sy_V[7:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_Sy_V[7:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_SY_V_DATA_0)
            int_Sy_V[7:0] <= (WDATA[31:0] & wmask) | (int_Sy_V[7:0] & ~wmask);
    end
end

// int_mode_V[0:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_mode_V[0:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_MODE_V_DATA_0)
            int_mode_V[0:0] <= (WDATA[31:0] & wmask) | (int_mode_V[0:0] & ~wmask);
    end
end

// int_relu_en_V[0:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_relu_en_V[0:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_RELU_EN_V_DATA_0)
            int_relu_en_V[0:0] <= (WDATA[31:0] & wmask) | (int_relu_en_V[0:0] & ~wmask);
    end
end


//------------------------Memory logic-------------------
// feature_in
assign int_feature_in_address0  = feature_in_address0 >> 1;
assign int_feature_in_ce0       = feature_in_ce0;
assign int_feature_in_we0       = 1'b0;
assign int_feature_in_be0       = 1'b0;
assign int_feature_in_d0        = 1'b0;
assign feature_in_q0            = int_feature_in_q0 >> (int_feature_in_shift * 16);
assign int_feature_in_address1  = ar_hs? raddr[7:2] : waddr[7:2];
assign int_feature_in_ce1       = ar_hs | (int_feature_in_write & WVALID);
assign int_feature_in_we1       = int_feature_in_write & WVALID;
assign int_feature_in_be1       = WSTRB;
assign int_feature_in_d1        = WDATA;
// W
assign int_W_address0           = W_address0 >> 1;
assign int_W_ce0                = W_ce0;
assign int_W_we0                = 1'b0;
assign int_W_be0                = 1'b0;
assign int_W_d0                 = 1'b0;
assign W_q0                     = int_W_q0 >> (int_W_shift * 16);
assign int_W_address1           = ar_hs? raddr[4:2] : waddr[4:2];
assign int_W_ce1                = ar_hs | (int_W_write & WVALID);
assign int_W_we1                = int_W_write & WVALID;
assign int_W_be1                = WSTRB;
assign int_W_d1                 = WDATA;
// bias
assign int_bias_address0        = bias_address0 >> 1;
assign int_bias_ce0             = bias_ce0;
assign int_bias_we0             = 1'b0;
assign int_bias_be0             = 1'b0;
assign int_bias_d0              = 1'b0;
assign bias_q0                  = int_bias_q0 >> (int_bias_shift * 16);
assign int_bias_address1        = ar_hs? raddr[7:2] : waddr[7:2];
assign int_bias_ce1             = ar_hs | (int_bias_write & WVALID);
assign int_bias_we1             = int_bias_write & WVALID;
assign int_bias_be1             = WSTRB;
assign int_bias_d1              = WDATA;
// feature_out
assign int_feature_out_address0 = feature_out_address0 >> 1;
assign int_feature_out_ce0      = feature_out_ce0;
assign int_feature_out_we0      = feature_out_we0;
assign int_feature_out_be0      = 3 << (feature_out_address0[0] * 2);
assign int_feature_out_d0       = {2{feature_out_d0}};
assign int_feature_out_address1 = ar_hs? raddr[7:2] : waddr[7:2];
assign int_feature_out_ce1      = ar_hs | (int_feature_out_write & WVALID);
assign int_feature_out_we1      = int_feature_out_write & WVALID;
assign int_feature_out_be1      = WSTRB;
assign int_feature_out_d1       = WDATA;
// int_feature_in_read
always @(posedge ACLK) begin
    if (ARESET)
        int_feature_in_read <= 1'b0;
    else if (ACLK_EN) begin
        if (ar_hs && raddr >= ADDR_FEATURE_IN_BASE && raddr <= ADDR_FEATURE_IN_HIGH)
            int_feature_in_read <= 1'b1;
        else
            int_feature_in_read <= 1'b0;
    end
end

// int_feature_in_write
always @(posedge ACLK) begin
    if (ARESET)
        int_feature_in_write <= 1'b0;
    else if (ACLK_EN) begin
        if (aw_hs && AWADDR[ADDR_BITS-1:0] >= ADDR_FEATURE_IN_BASE && AWADDR[ADDR_BITS-1:0] <= ADDR_FEATURE_IN_HIGH)
            int_feature_in_write <= 1'b1;
        else if (WVALID)
            int_feature_in_write <= 1'b0;
    end
end

// int_feature_in_shift
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (feature_in_ce0)
            int_feature_in_shift <= feature_in_address0[0];
    end
end

// int_W_read
always @(posedge ACLK) begin
    if (ARESET)
        int_W_read <= 1'b0;
    else if (ACLK_EN) begin
        if (ar_hs && raddr >= ADDR_W_BASE && raddr <= ADDR_W_HIGH)
            int_W_read <= 1'b1;
        else
            int_W_read <= 1'b0;
    end
end

// int_W_write
always @(posedge ACLK) begin
    if (ARESET)
        int_W_write <= 1'b0;
    else if (ACLK_EN) begin
        if (aw_hs && AWADDR[ADDR_BITS-1:0] >= ADDR_W_BASE && AWADDR[ADDR_BITS-1:0] <= ADDR_W_HIGH)
            int_W_write <= 1'b1;
        else if (WVALID)
            int_W_write <= 1'b0;
    end
end

// int_W_shift
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (W_ce0)
            int_W_shift <= W_address0[0];
    end
end

// int_bias_read
always @(posedge ACLK) begin
    if (ARESET)
        int_bias_read <= 1'b0;
    else if (ACLK_EN) begin
        if (ar_hs && raddr >= ADDR_BIAS_BASE && raddr <= ADDR_BIAS_HIGH)
            int_bias_read <= 1'b1;
        else
            int_bias_read <= 1'b0;
    end
end

// int_bias_write
always @(posedge ACLK) begin
    if (ARESET)
        int_bias_write <= 1'b0;
    else if (ACLK_EN) begin
        if (aw_hs && AWADDR[ADDR_BITS-1:0] >= ADDR_BIAS_BASE && AWADDR[ADDR_BITS-1:0] <= ADDR_BIAS_HIGH)
            int_bias_write <= 1'b1;
        else if (WVALID)
            int_bias_write <= 1'b0;
    end
end

// int_bias_shift
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (bias_ce0)
            int_bias_shift <= bias_address0[0];
    end
end

// int_feature_out_read
always @(posedge ACLK) begin
    if (ARESET)
        int_feature_out_read <= 1'b0;
    else if (ACLK_EN) begin
        if (ar_hs && raddr >= ADDR_FEATURE_OUT_BASE && raddr <= ADDR_FEATURE_OUT_HIGH)
            int_feature_out_read <= 1'b1;
        else
            int_feature_out_read <= 1'b0;
    end
end

// int_feature_out_write
always @(posedge ACLK) begin
    if (ARESET)
        int_feature_out_write <= 1'b0;
    else if (ACLK_EN) begin
        if (aw_hs && AWADDR[ADDR_BITS-1:0] >= ADDR_FEATURE_OUT_BASE && AWADDR[ADDR_BITS-1:0] <= ADDR_FEATURE_OUT_HIGH)
            int_feature_out_write <= 1'b1;
        else if (WVALID)
            int_feature_out_write <= 1'b0;
    end
end

// int_feature_out_shift
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (feature_out_ce0)
            int_feature_out_shift <= feature_out_address0[0];
    end
end


endmodule


`timescale 1ns/1ps

module Conv_AXILiteS_s_axi_ram
#(parameter
    BYTES  = 4,
    DEPTH  = 256,
    AWIDTH = log2(DEPTH)
) (
    input  wire               clk0,
    input  wire [AWIDTH-1:0]  address0,
    input  wire               ce0,
    input  wire               we0,
    input  wire [BYTES-1:0]   be0,
    input  wire [BYTES*8-1:0] d0,
    output reg  [BYTES*8-1:0] q0,
    input  wire               clk1,
    input  wire [AWIDTH-1:0]  address1,
    input  wire               ce1,
    input  wire               we1,
    input  wire [BYTES-1:0]   be1,
    input  wire [BYTES*8-1:0] d1,
    output reg  [BYTES*8-1:0] q1
);
//------------------------Local signal-------------------
reg  [BYTES*8-1:0] mem[0:DEPTH-1];
//------------------------Task and function--------------
function integer log2;
    input integer x;
    integer n, m;
begin
    n = 1;
    m = 2;
    while (m < x) begin
        n = n + 1;
        m = m * 2;
    end
    log2 = n;
end
endfunction
//------------------------Body---------------------------
// read port 0
always @(posedge clk0) begin
    if (ce0) q0 <= mem[address0];
end

// read port 1
always @(posedge clk1) begin
    if (ce1) q1 <= mem[address1];
end

genvar i;
generate
    for (i = 0; i < BYTES; i = i + 1) begin : gen_write
        // write port 0
        always @(posedge clk0) begin
            if (ce0 & we0 & be0[i]) begin
                mem[address0][8*i+7:8*i] <= d0[8*i+7:8*i];
            end
        end
        // write port 1
        always @(posedge clk1) begin
            if (ce1 & we1 & be1[i]) begin
                mem[address1][8*i+7:8*i] <= d1[8*i+7:8*i];
            end
        end
    end
endgenerate

endmodule

