/*
:name: arrays-packed-quering-functions-unpacked-dimensions
:description: Test quering functions support on packed arrays
:should_fail: 0
:tags: 7.11 7.4.1
*/
module top ();

bit [7:0] arr;

initial begin
	$display(":assert: (%d == 0)", $unpacked_dimensions(arr));
end

endmodule
