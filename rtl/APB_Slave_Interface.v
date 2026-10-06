module APB_Slave_Interface(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,ss,tip,data_miso,receive_data,prdata,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,sir,send_data,data_mosi,spi_mode,pready,pslverr);

 input pclk,preset_n;
 input [2:0]paddr;
 input pwrite,psel,penable;
 input [7:0]pwdata;
 input ss,tip;
 input [7:0]data_miso;
 input receive_data;
 

 output reg [7:0]prdata;
 output mstr;
 output cpol,cpha;
 output lsbfe,spiswai;
 output [2:0]sppr,spr;
 output reg sir;
 output reg send_data;
 output reg [7:0] data_mosi;
 output reg [1:0]spi_mode;
 output pready,pslverr;

 reg [2:0] s,ns;
 reg [1:0] nm;

// 5 registers
	reg [7:0] SPICR1,SPICR2,SPIBR,SPISR,SPIDR;


 wire spe;
 wire rd_enb,wr_enb;
 wire [7:0] cr2_mask = 8'h1b;
 wire [7:0] br_mask = 8'h77;
 wire spif,sptef,modf;

 
 parameter IDLE = 3'b100,
	   SETUP = 3'b101,
	   ENABLE = 3'b110;

 parameter RUN = 2'b00,
	   WAIT = 2'b01,
 	   STOP = 2'b10;


// APB FSM
always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			s <= IDLE;
		else
			s <= ns;
	end

always@(*)
	begin 
		case(s) 
				IDLE: begin
					if( psel && !penable )
						ns <= SETUP;
					else if ( psel && penable)
						ns <= ENABLE;
					else
						ns <= IDLE;
				      end
						
				SETUP: begin
					if( psel && penable )
						ns <= ENABLE;
					else if ( psel && !penable)
						ns <= SETUP;
					else
						ns <= IDLE;
				       end

				ENABLE: begin
					if( psel && !penable )
						ns <= SETUP;
					else
						ns <= IDLE;
					end
				default: ns <= IDLE;
		endcase

	end




// SPI FSM
always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			spi_mode <= RUN;
		else
			spi_mode <= nm;
	end

always@(*)
	begin 
		case(spi_mode) 
				RUN: begin
					if( !spe && !spiswai )
						nm <= WAIT;
					else
						nm <= RUN;
				     end
						
				WAIT: begin
					if( !spe && spiswai )
						nm <= STOP;
					else if ( !spe && !spiswai )
						nm <= WAIT;
					else
						nm <= RUN;
				      end

				STOP: begin
					if( !spe && !spiswai )
						nm <= WAIT;
					else
						nm <= RUN;
				      end
				default: nm <= RUN;
				
		endcase

	end


// read enable and write enable
assign rd_enb = (!pwrite && (s == ENABLE))?1'b1:1'b0;
assign wr_enb = (pwrite && (s == ENABLE))?1'b1:1'b0;

// palverr and pready
assign pslverr = (s == ENABLE)? !tip: 1'b0;
assign pready = (s == ENABLE)? 1'b1: 1'b0;



// SPICR1 Register Writing
/*
   bits      7       6         5        4       3        2         1        0 
   ------------------------------------------------------------------------------
  |  R  |  SPIE  |  SPE  |  SPTIE  |  MSTR  |  CPOL  |  CPHA  |  SSOE  |  LSBFE  |
  |  w  |        |       |         |        |        |        |        |         |
   ------------------------------------------------------------------------------
   Reset:    0       0         0        0       0        1         0        0     
*/
always@(posedge pclk or negedge preset_n)
	begin	
		if(!preset_n)
			SPICR1 <= 8'd4;
		else
			begin 
				if(wr_enb)
					begin 
						if(paddr == 3'b000)
							SPICR1 <= pwdata;
						else
							SPICR1 <= SPICR1;
					end
				else
					SPICR1 <= SPICR1;
			end

	end



// SPICR2 Register Writing
/*
   bits      7       6         5        4       3        2         1        0 
   ------------------------------------------------------------------------------
  |  R  |    0   |   0   |    0    | MODFEN | BIDIRO |   0    | SPISWAI |  SPCO   |
  |  w  |    x   |   x   |    x    |        |        |   x    |         |         |
   ------------------------------------------------------------------------------
   Reset:    0       0         0        0       0        0         0        0     
*/
always@(posedge pclk or negedge preset_n)
	begin	
		if(!preset_n)
			SPICR2 <= 8'd0;
		else
			begin 
				if(wr_enb)
					begin 
						if(paddr == 3'b001)
							SPICR2 <= pwdata & cr2_mask;
						else
							SPICR2 <= SPICR2;
					end
				else
					SPICR2 <= SPICR2;
			end

	end



// SPIBR Register Writing
/*
   bits      7       6         5        4       3        2         1        0 
   ------------------------------------------------------------------------------
  |  R  |    0   | SPPR2 |  SPPR1  | SPPR0  |   0    |  SPR2  |  SPR1  |  SPR0   |
  |  w  |    x   |       |         |        |   x    |        |        |         |
   ------------------------------------------------------------------------------
   Reset:    0       0         0        0       0        0         0        0     
*/
always@(posedge pclk or negedge preset_n)
	begin	
		if(!preset_n)
			SPIBR <= 8'd0;
		else
			begin 
				if(wr_enb)
					begin 
						if(paddr == 3'b010)
							SPIBR <= pwdata & br_mask;
						else
							SPIBR <= SPIBR;
					end
				else
					SPIBR <= SPIBR;
			end

	end


// SPIDR Register Writing
/*
   bits      7       6         5        4       3        2         1        0 
   ------------------------------------------------------------------------------
  |  R  |    7   |   6   |    5    |   4    |   3    |   2    |    1   |    0    |
  |  w  |        |       |         |        |        |        |        |         |
   ------------------------------------------------------------------------------
   Reset:    0       0         0        0       0        0         0        0     
*/
always@(posedge pclk or negedge preset_n)
	begin	
		if(!preset_n)
			begin
				SPIDR <= 8'd0;
				send_data <= 1'b0;
				data_mosi <= 8'd0; 
			end
		else 
			begin 
				if(wr_enb)
					begin 
						if(paddr == 3'b101)
							SPIDR <= pwdata;
						else
							SPIDR <= SPIDR;
					end
				else
					begin
						if((SPIDR == pwdata) && (SPIDR != data_miso) && ((spi_mode == RUN) ||(spi_mode == WAIT)))
							begin
								send_data <= 1'b1;
								SPIDR <= 8'd0;
								data_mosi <= SPIDR;
							end
						else
							begin 
								send_data <= 1'b0;
								data_mosi <= data_mosi;
								if (receive_data && ((spi_mode == RUN) || (spi_mode == WAIT)))
									SPIDR <= data_miso;
								else
									SPIDR <= SPIDR;
							end
					end
			end
	end


// SPISR Register Updating
/*
   bits      7       6         5        4       3        2         1        0 
   ------------------------------------------------------------------------------
  |  R  |  SPIF  |   0   |  SPTEF  |  MODF  |   0    |   0    |    0   |    0    |
  |  w  |    x   |   x   |    x    |    x   |   x    |   x    |    x   |    x    |
   ------------------------------------------------------------------------------
   Reset:    0       0         0        0       0        0         0        0     
*/
always@(*)
	begin 
		SPISR = (preset_n)? 8'b00100000 : {spif,1'b0,sptef,modf,4'b0};
	end



//SPICR1 Bits
assign lsbfe = SPICR1[0];
assign ssoe  = SPICR1[1];
assign cpha  = SPICR1[2];
assign cpol  = SPICR1[3];
assign mstr  = SPICR1[4];
assign sptie = SPICR1[5];
assign spe   = SPICR1[6];
assign spie  = SPICR1[7];

//SPICR2 Bits
assign spiswai = SPICR2[1];
assign modfen  = SPICR2[4];

//SPIBR Bits
assign spr  = SPIBR[2:0];
assign sppr = SPIBR[6:4];

//SPISR Bits
assign modf  = ~ss & mstr & modfen & ~ssoe;
assign sptef = (SPIDR == 8'd0)? 1'b1:1'b0;
assign spif  = (SPIDR != 8'b0)? 1'b1:1'b0;


// All Registers Read Logic
always@(*)
	begin 
		if(!rd_enb)
			begin
				prdata = 8'b0;
			end
		else
			case(paddr)
				3'b000: prdata = SPICR1;
				3'b001: prdata = SPICR2;
				3'b010: prdata = SPIBR;
				3'b011: prdata = SPISR;
				3'b101: prdata = SPIDR;
				default: prdata = 8'b0;
			endcase
	end


// SPI Interrupt Request
always@(*)
	begin	
		if(~spie & ~sptie)
			sir <= 1'b0;
		else
			begin 
				if(~sptie & ~spie)
					sir <= spif | modf;
				else
					begin
						if(sptie & !spie)
							sir <= sptef;
						else
							sir <= spif | modf | sptef; 
					end
			end
			
	end

endmodule