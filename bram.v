module bram(clk, we, a, di, do);

input	clk;
input	we;
input	[10:0] a;
input	[7:0] di;
output	[7:0] do;
reg	[7:0] ram [63:0];
reg	[10:0] read_a;

always @(posedge clk) begin
	if (we)
		ram[a] <= di;
	read_a <= a;
end

assign do = ram[read_a];

initial
begin
	$readmemh("ram.data", ram);
end
endmodule
