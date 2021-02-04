`timescale 1ns / 1ps

module test_ov5642_interface();

reg [7:0] din = 0;
reg href = 0;
reg vsync = 0;

reg clk = 1;
always #5 clk = ~clk;


wire [7:0] tdata;
wire tlast, tvalid;
ov5642_interface uut(
     .pclk(clk)
    ,.din(din)
    ,.href(href)
    ,.vsync(vsync)
    ,.tdata(tdata)
    ,.tlast(tlast)
    ,.tvalid(tvalid)
);

ov5642_byte_aligner ba(
     .pclk(clk)
    ,.tdata_in(tdata)
    ,.tlast_in(tlast)
    ,.tvalid_in(tvalid)
);

always @(negedge clk)
    din <= din + 1;

initial begin
    #5;
    while (1) begin
        #100;
        href = 1;
        #100;
        href = 0;
        #100;
        href = 1;
        #100;
        href = 0;
        #50;
        vsync = 1;
        #100;
        vsync = 0;
    end
end

endmodule
