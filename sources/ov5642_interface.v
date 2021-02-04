`timescale 1ns / 1ps

module ov5642_interface (
    input pclk,
    input [7:0] din,
    input href,
    input vsync,

    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN pclk" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
    output [7:0] tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *)
    output tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
    output tvalid
);

/*
 * Rename clock
 */
wire clk;
assign clk = pclk;

/*
 * Detect VSYNC posedge
 */
reg prev_vsync;
always @(posedge clk)
    prev_vsync <= vsync;

wire vsync_posedge;
assign vsync_posedge = vsync & prev_vsync;

/*
 * Store incmoing data
 */
reg [7:0] dreg;

always @(posedge clk)
    if (href)
        dreg <= din;

reg dreg_valid;

always @(posedge clk)
    if (href)
        dreg_valid <= 1'b1;
    else if (vsync_posedge)
        dreg_valid <= 1'b0;

/*
 * Set stream outputs
 */
assign tdata = dreg;                                    // the last received byte is transmitted

assign tlast = vsync_posedge & dreg_valid;              // the last pixel is transmitted when VSYNC is received

assign tvalid = dreg_valid & (href | vsync_posedge);    // the output is valid when dreg has valid data,
                                                        // and either the next row started, or vsync was asserted

endmodule
