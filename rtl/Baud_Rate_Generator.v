module Baud_Rate_Generator(pclk,preset_n,spi_mode,spiswai,sppr,spr,cpol,cpha,ss,sclk,mrs1,mrs0,mss1,mss0,baudratedivisor);

 input pclk,preset_n;
 input [1:0]spi_mode;
 input spiswai;
 input [2:0]sppr,spr;
 input cpol,cpha;
 input ss;

 output reg sclk;
 output reg mrs1,mrs0,mss1,mss0;
 output [11:0]baudratedivisor;

 reg [11:0]count;
 wire prclk;

assign prclk = cpol?1'b1:1'b0;
assign baudratedivisor = (sppr+1'b1)*(2**(spr+1'b1));

// clock generator

always@(posedge pclk or negedge preset_n)
    begin
        if(!preset_n)
            begin
                sclk <= prclk;
                count<=12'd0;
            end
        else if((spi_mode==2'b00 || (spi_mode==2'b01 && spiswai==1'b0)) && ss==1'b0)
            begin
                if(count==((baudratedivisor/2)-1'b1))
                    begin
                        count<=12'd0;
                        sclk<=~sclk;
                    end
                else
                    begin
                        count<=count+12'd1;
                        sclk<=sclk;
                    end
            end
        else
            begin
                sclk<=sclk;
                count<=12'd0;
            end
    end


//mrs0 and mrs1

always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
            		begin
                		mrs0<=1'b0;
				mrs1<=1'b0;
           		end

		else	
			begin
		if( ((!cpha)&cpol) | ((!cpol)&cpha) )
			begin
				if(sclk)
					begin
						if(count==((baudratedivisor/2)-1'b1))
							begin
								mrs0<=1'b1;
								mrs1<=1'b0;
							end
						else
							begin
								mrs0<=1'b0;
								mrs1<=1'b0;
							end
					end
				else
					begin
						mrs0<=1'b0;
						mrs1<=1'b0;
					end
			end
		else
			begin
				if(~sclk)
					begin
						if(count==((baudratedivisor/2)-1'b1))
							begin
								mrs0<=1'b0;
								mrs1<=1'b1;
							end
						else
							begin
								mrs0<=1'b0;
								mrs1<=1'b0;
							end
					end
				else
					begin
						mrs0<=1'b0;
						mrs1<=1'b0;
					end
			end
		end
	end



//mss0 and mss1

always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
            		begin
                		mss0<=1'b0;
				mss1<=1'b0;
           		end
		else
			begin
		if( ((!cpha)&cpol) | ((!cpol)&cpha) )
			begin
				if(sclk)
					begin
						if(count==((baudratedivisor/2)-2'b10))
							begin
								mss0<=1'b1;
								mss1<=1'b0;
							end
						else
							begin
								mss0<=1'b0;
								mss1<=1'b0;
							end
					end
				else
					begin
						mss0<=1'b0;
						mss1<=1'b0;
					end
			end
		else
			begin
				if(~sclk)
					begin
						if(count==((baudratedivisor/2)-2'b10))
							begin
								mss0<=1'b0;
								mss1<=1'b1;
							end
						else
							begin
								mss0<=1'b0;
								mss1<=1'b0;
							end
					end
				else
					begin
						mss0<=1'b0;
						mss1<=1'b0;
					end
			end
		end
	end






endmodule
