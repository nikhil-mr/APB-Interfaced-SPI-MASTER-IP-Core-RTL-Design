module Top_Block(
    pclk, preset_n, paddr, pwrite, penable, psel,
    pwdata, pready, pslverr, ss, sclk, prdata,
    sir, mosi, miso
);

    input pclk, preset_n;
    input [2:0] paddr;
    input pwrite, penable, psel;
    input [7:0] pwdata;
    input miso;

    output pready, pslverr;
    output ss, sclk;
    output [7:0] prdata;
    output sir;
    output mosi;

    wire tip;

    wire mstr;
    wire cpol, cpha;
    wire lsbfe, spiswai;

    wire [2:0] sppr, spr;
    wire [1:0] spi_mode;

    wire send_data;
    wire receive_data;

    wire [7:0] data_miso;
    wire [7:0] data_mosi;

    wire [11:0] baudratedivisor;

    wire mrs1, mrs0;
    wire mss1, mss0;

   // Block 1: APB Slave Interface
APB_Slave_Interface B1(
    pclk, preset_n, paddr, pwrite, psel, penable, pwdata,
    ss, tip, data_miso, receive_data,
    prdata, mstr, cpol, cpha, lsbfe, spiswai, sppr, spr,
    sir, send_data, data_mosi, spi_mode, pready, pslverr
);


// Block 2: Baud Rate Generator
Baud_Rate_Generator B2(
    pclk, preset_n, spi_mode, spiswai, sppr, spr, cpol, cpha,
    ss, sclk, mrs1, mrs0, mss1, mss0, baudratedivisor
);


// Block 3: Shift Register
Shift_register B3(
    pclk, preset_n, ss, send_data, lsbfe, cpha, cpol,
    mrs1, mrs0, mss1, mss0, data_mosi, miso, receive_data,
    mosi, data_miso
);


// Block 4: SPI Slave Select Control
SPI_Slave_Select_Block B4(
    pclk, preset_n, mstr, spiswai, spi_mode, send_data,
    baudratedivisor, receive_data, ss, tip
);
endmodule
