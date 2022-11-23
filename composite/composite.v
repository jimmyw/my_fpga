

module composite (
    input clk,
    output vout, sync_
);

reg [2:0] count;
wire clk10 = count[2];
always @(posedge clk) begin
    if (count == 4)
        count <= 0;
    else
        count <= count + 1;
end

reg [9:0] xpos;
reg [8:0] ypos;
always @(posedge clk10) begin
    if (xpos == 639) begin
        xpos <= 0;
        if (ypos == 311)
            ypos <= 0;
        else
            ypos <= ypos + 1;
    end else
        xpos <= xpos + 1;
end

wire active = xpos < 490 && ypos < 268;
wire hsync = 528 <= xpos && xpos < 575;
wire vsync = 276 <= ypos && ypos < 279;

assign vout = active && (xpos == 0 || xpos == 489 || ypos == 0 || ypos == 267);
assign sync_ = active || !(hsync || vsync);

endmodule



