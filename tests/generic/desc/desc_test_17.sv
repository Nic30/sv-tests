/*
:name: desc_test_17
:description: Test
:should_fail: 0
:tags: 5.6.4
*/
`ifdef ASIC_OR_FPGA
module module_asic;
endmodule
module module_fpga;
endmodule
`else
`endif
