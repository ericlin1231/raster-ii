module tmds_encoder(
  input clk,
  input [7:0] data,
  input [1:0] ctrl,
  input de,
  output reg [9:0] tmds
);

  integer i;
  reg [3:0] data_ones;
  reg [8:0] temp;
  reg [3:0] temp_ones;
  always @(data) begin
    data_ones = 4'h0;
    for (i = 0; i < 8; i = i + 1) begin
      data_ones = data_ones + data[i];
    end

    temp[0] = data[0];
    if (data_ones > 4'h4 || data_ones == 4'h4 && ~data[0]) begin
      for (i = 1; i < 8; i = i + 1) begin
        temp[i] = ~(temp[i - 1] ^ data[i]);
      end
      temp[8] = 1'b0;
    end else begin
      for (i = 1; i < 8; i = i + 1) begin
        temp[i] = temp[i - 1] ^ data[i];
      end
      temp[8] = 1'b1;
    end

    temp_ones = 4'h0;
    for (i = 0; i < 8; i = i + 1) begin
      temp_ones = temp_ones + temp[i];
    end
  end

  reg [4:0] cnt;
  always @(posedge clk) begin
    if (~de) begin
      case(ctrl)
        2'b00 : tmds <= 10'b1101010100;
        2'b01 : tmds <= 10'b0010101011;
        2'b10 : tmds <= 10'b0101010100;
        default : tmds <= 10'b1010101011;
      endcase
      cnt <= 5'h0;
    end
    else begin
      if (cnt == 5'h0 || temp_ones == 4'h4) begin
        tmds <= {~temp[8], temp[8], temp[8] ? temp[7:0] : ~temp[7:0]};
        cnt <= ~temp[8] ? cnt + 5'h8 - (temp_ones << 1) : cnt + (temp_ones << 1) - 5'h8;
      end
      else begin
        if ((~cnt[4] && temp_ones > 4'h4) || (cnt[4] && temp_ones < 4'h4)) begin
          tmds <= {1'b1, temp[8], ~temp[7:0]};
          cnt <= cnt + (temp[8] << 1) + 5'h8 - (temp_ones << 1);
        end
        else begin
          tmds <= {1'b0, temp[8], temp[7:0]};
          cnt <= cnt - (~temp[8] << 1) + (temp_ones << 1) - 5'h8;
        end
      end
    end
  end

endmodule
