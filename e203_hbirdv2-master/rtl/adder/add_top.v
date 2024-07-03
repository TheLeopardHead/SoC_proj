// +FHDR----------------------------------------------------------------------------
// Project Name  : Soc_lab1
// Author        : LKai-Xu
// Created On    : 2022/06/04 20:50
// Last Modified : 2023/03/21 20:56
// File Name     : icb_slave.v
// Description   : icb slave module
//
//
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/06/04   LKai-Xu         1.0                     Original
// 2023/03/21   Lisp           
// -FHDR----------------------------------------------------------------------------

`timescale 1ns/1ps


module add_top
(
input                           clk,
input                           rst_n,

// icb slave
input                           icb_cmd_valid,
output                          icb_cmd_ready,
input                           icb_cmd_read,
input       [31:0]              icb_cmd_addr,
input       [31:0]              icb_cmd_wdata,
input       [3:0]               icb_cmd_wmask,

output                          icb_rsp_valid,
input                           icb_rsp_ready,
output      [31:0]              icb_rsp_rdata,
output                          icb_rsp_err

);
    wire [31:0]                 ADDEND                         ;
    wire [31:0]                 AUGEND                         ;
    wire                        CONTROL                         ;
    wire [31:0]                 SUM                        ;
    wire                        OVERFLOW;
    

// slave interface
icb_slave icb_slave_u(
    
        .icb_cmd_valid          (icb_cmd_valid                  ), //input
        .icb_cmd_ready          (icb_cmd_ready                  ), //output
        .icb_cmd_read           (icb_cmd_read                   ), //input
        .icb_cmd_addr           (icb_cmd_addr[31:0]             ), //input
        .icb_cmd_wdata          (icb_cmd_wdata[31:0]            ), //input
        .icb_cmd_wmask          (icb_cmd_wmask[3:0]             ), //input
        .icb_rsp_valid          (icb_rsp_valid                  ), //output
        .icb_rsp_ready          (icb_rsp_ready                  ), //input
        .icb_rsp_rdata          (icb_rsp_rdata[31:0]            ), //output
        .icb_rsp_err            (icb_rsp_err                    ), //output
        .clk                    (clk                            ), //input
        .rst_n                  (rst_n                          ), //input
        .AUGEND                 (AUGEND[31:0]               ), //output
        .ADDEND                 (ADDEND[31:0]               ), //output]
        .CONTROL                (CONTROL               ), //output
        .SUM                    (SUM   [31:0]            ),
        .OVERFLOW               (OVERFLOW)
    );


// control
adder u_adder(
    .clk               (clk),
    .rst_n             (rst_n),
    .in1               (AUGEND[31:0]),
    .in2               (ADDEND[31:0]),
    .out               (SUM[31:0]),
    .enable             (CONTROL),    
    .overflow           (OVERFLOW)

);
endmodule

