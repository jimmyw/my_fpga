

`include "composite.v"

module top (
    output vout, sync_, debug,
);


wire clk;

SB_HFOSC inthosc (
  .CLKHFPU(1'b1),
  .CLKHFEN(1'b1),
  .CLKHF(clk)
);
// Hard divide by 1, makes it 24Mhz
defparam inthosc.CLKHF_DIV = "0b01";

wire clock_out;
reg[27:0] counter=28'd0;
parameter DIVISOR = 28'd2;

always @(posedge clk)
begin
    // Increase counter with one
    counter <= counter + 28'd1;
    // If hit divisor
    if(counter>=(DIVISOR-1))
        // Restart from zero
        counter <= 28'd0;

    // Output if counter is more or less than half
    clock_out <= (counter<DIVISOR/2) ? 1'b1 : 1'b0;
end

//assign debug = clock_out;
// Takes a clock if 78.750khz
composite c(clock_out, vout, sync_, debug);



endmodule
