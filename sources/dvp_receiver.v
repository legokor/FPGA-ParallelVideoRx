`timescale 1ns / 1ps

module dvp_receiver #(
    parameter VSYNC_ACTIVE_HIGH = 0,
    parameter HREF_ACTIVE_HIGH = 1
) (
    input pclk,
    input [7:0] din,
    input href_in,
    input vsync_in,

    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN pclk" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_VIDEO TDATA" *)
    output [7:0] tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_VIDEO TLAST" *)
    output tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_VIDEO TVALID" *)
    output tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_VIDEO TUSER" *)
    output tuser
);

/*
 * Invert HREF and VSYNC if necessary
 */
wire href, vsync;
assign href  = HREF_ACTIVE_HIGH  ? href_in  : ~href_in;
assign vsync = VSYNC_ACTIVE_HIGH ? vsync_in : ~vsync_in;

/*
 * Rename clock
 */
wire clk;
assign clk = pclk;

/*
 * Store incoming data
 */
reg [7:0] dreg;

always @(posedge clk)
    if (href)
        dreg <= din;

reg dreg_valid;
always @(posedge clk)
    dreg_valid <= href;

/*
 * Start-of-Frame is active until the first byte after a VSYNC pulse
 */
reg sof;
always @(posedge clk)
    if (vsync)
        sof <= 1'b1;
    else if (dreg_valid)
        sof <= 1'b0;


/*
 * Set stream outputs
 */
assign tdata = dreg;
assign tlast = dreg_valid & ~href;             // Activate TLAST when HREF ends
assign tvalid = dreg_valid;
assign tuser = sof & dreg_valid;               // Activate SOF only for a single transaction

endmodule
