module complex_div

(
    input clock,
    input enable,
    input reset,

    input [15:0] a_i,
    input [15:0] a_q,
    input [15:0] b_i,
    input [15:0] b_q,
    input input_strobe,

    output wire [31:0]  p_i ,
    output wire [31:0]  p_q ,
    output output_strobe
);

localparam DELAY = 4;
reg [DELAY-1:0] delay;

reg [15:0] ar;
reg [15:0] ai;
reg [15:0] br;
reg [15:0] bi;

wire [31:0] prod_i;
wire [31:0] prod_q;

wire [31:0] mag;

wire         temp_strobe;
complex_multiplier sq_ins1 (
    .clk(clock),
    .ar(br),
    .ai(bi),
    .br(br),
    .bi(~bi+'d1),
    .pr(mag),
    .pi()
);

complex_multiplier mult_inst (
    .clk(clock),
    .ar(ar),
    .ai(ai),
    .br(br),
    .bi(bi),
    .pr(prod_i),
    .pi(prod_q)
);


divider csi_ratio_re (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .dividend( prod_i),
    .divisor( mag[31:8]),
    .input_strobe(temp_strobe),

    .quotient(p_i),
    .output_strobe(output_strobe)
);

divider csi_ratio_im (
    .clock(clock),
    .enable(enable), 
    .reset(reset),

    .dividend( prod_i ),
    .divisor(  mag[31:8] ),
    .input_strobe(temp_strobe),

    .quotient(p_q)
);


delayT #(.DATA_WIDTH(1), .DELAY(4)) stb_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in(input_strobe),
    .data_out(temp_strobe)
);

always @(posedge clock) begin
    if (reset) begin
        ar <= 0;
        ai <= 0;
        br <= 0;
        bi <= 0;
        delay <= 0;
    end else if (enable) begin
        ar <= a_i;
        ai <= a_q;
        br <= b_i;
        bi <= ~b_q +'d1;
    end
end

endmodule
