/*
:name: unsigned_func
:description: $unsigned() test
:should_fail: 0
:tags: 11.7
*/
module top();

logic [7:0] a;

initial begin
	a = $unsigned(-4);
end

endmodule
