`timescale 1ns / 1ps

module ov5642_byte_aligner(
    input pclk,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA"  *) input [7:0] tdata_in,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST"  *) input tlast_in,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input tvalid_in,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA"  *) output [15:0] tdata_out,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST"  *) output tlast_out,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) output tvalid_out,

    output [7:0] red_out,
    output [7:0] blue_out,
    output [7:0] green_out,
    output valid,
    output last
);

wire clk;
assign clk = pclk;

reg init = 0;
always @(posedge clk)
    if (tlast_in)
        init <= 1;


reg frame_active = 0;
always @(posedge clk)
    if (tlast_in)
        frame_active <= 0;
    else if (tvalid_in)
        frame_active <= 1;

reg [7:0] data0;
reg [7:0] data1;
wire [15:0] data;

reg rs = 0;
always @(posedge clk)
    if (init && tvalid_in)
        rs <= ~rs;

always @(posedge clk)
    if (init && tvalid_in)
        if (rs)
            data1 <= tdata_in;
        else
            data0 <= tdata_in;

reg last_bit;
always @(posedge clk)
    if (tlast_in && tvalid_in)
        last_bit <= 1;
    else
        last_bit <= 0;

assign tdata_out = {data0, data1};
assign tvalid_out = (init && frame_active && tvalid_in && !rs) | last_bit;
assign tlast_out = last_bit;

assign blue_out  = {tdata_out[15:11], 3'b0};
assign green_out = {tdata_out[10: 5], 2'b0};
assign red_out   = {tdata_out[ 4: 0], 3'b0};
assign valid = tvalid_out;
assign last = tlast_out;

endmodule
