

module composite (
    input clk10, // optimal is 13.34Mhz, fed by 12Mhz
    output vout, sync_, debug
);

// http://www.batsocks.co.uk/readme/video_timing.htm
// https://web.archive.org/web/20190920131436/http://www.radios-tv.co.uk:80/Pembers/World-TV-Standards/Line-Standards.html
// https://web.archive.org/web/20180714045345if_/http://www.radios-tv.co.uk:80/Pembers/World-TV-Standards/HBI.pdf
// https://web.archive.org/web/20170614080644if_/http://www.radios-tv.co.uk/Pembers/World-TV-Standards/VBI-625-PAL.pdf

reg [10:0] xpos;
reg [10:0] ypos;
reg long_sync;
reg short_sync;
reg line_sync;
reg active;
reg [11:0] half_scanline = 11'b0;
reg [11:0] pos = 11'b0;
always @(posedge clk10) begin
    if (pos == (765/2)) begin
        pos <= 0;
        if (half_scanline == (624 * 2)) begin
            half_scanline <= 0;
        end else begin
            half_scanline <= half_scanline + 1;
        end
    end else begin
        pos <= pos + 1;
    end

    // 854 samples equals to one scanline of 64us
    // That is a new state every 0.0749us
    /*
    if (xpos == 854) begin
        xpos <= 0;
        if (ypos == 625)
            ypos <= 0;
        else
            ypos <= ypos + 1;
    end else
        xpos <= xpos + 1;*/
    if (half_scanline <= 4)
        long_sync <= 1;
    else if (half_scanline >= 625 && half_scanline <= 629)
        long_sync <= 1;
    else
        long_sync <= 0;

    if (half_scanline >= 5 && half_scanline <= 9)
        short_sync <= 1;
    else if (half_scanline >= 618 && half_scanline <= 624)
        short_sync <= 1;
    else if (half_scanline >= 630 && half_scanline <= 634)
        short_sync <= 1;
    else if (half_scanline >= 1245 )
        short_sync <= 1;
    else
        short_sync <= 0;

    if (half_scanline >= 10 && half_scanline <= 619)
        line_sync <= 1;
    else if (half_scanline >= 636 && half_scanline <= 1244)
        line_sync <= 1;
    else
        line_sync <= 0;

    if (half_scanline >= 45 && half_scanline <= 622) begin
        active <= 1;
        if (half_scanline[0] == 0)
            xpos <= pos;
        else
           xpos <= pos + (765/2);
        ypos <= half_scanline - 45;
    end else if (half_scanline >= 670 && half_scanline <= 1245) begin
        active <= 1;
        if (half_scanline[0] == 0)
            xpos <= pos;
        else
           xpos <= pos + (765/2);
        ypos <= half_scanline - 670;
    end else begin
        active <= 0;
    end
end



// Line sync pulse with is 4.7us (62 samples)
//wire y_active = (ypos > 22 && ypos < 310) || (ypos > 335 && ypos < 624);
wire line_sync_pulse = line_sync  && half_scanline[0] == 0 && pos < 57;



// Short sync pulse is 2.35us (31 samples)
wire short_sync_pulse = short_sync && pos < 27;

// Long sync pulse is 27.3us (364 samples)
wire long_sync_pulse = long_sync && pos < 330;


//wire active = y_active && xpos > 139 && xpos <= 831;

// Active line in active display
//assign vout = active;//(xpos == 139 || xpos == 831);
//assign vout = 1;
parameter HORIZ_ACTIVE_START = 122;
parameter HORIZ_ACTIVE_END = 740;

assign sync_ = !(short_sync_pulse || long_sync_pulse || line_sync_pulse);
assign vout = active && ((xpos >= HORIZ_ACTIVE_START && xpos <= 239) || (xpos >= 600 && xpos <= HORIZ_ACTIVE_END) || (xpos >= HORIZ_ACTIVE_START && ypos < 100 && xpos <= HORIZ_ACTIVE_END));
assign debug = half_scanline >= 0 && half_scanline < 10;

//||
  //          long_sync_pulse ||
    //        line_sync_pulse);
endmodule



