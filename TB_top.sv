module tb;
  inter inf();
  dual_port_ram DUT(.data(inf.data),.addr(inf.addr),.out(inf.out),.wr(inf.wr),.cs(inf.cs));
  
  initial
    begin
      uvm_config_db #(virtual inter)::set(null,"*","inf",inf);
      run_test("test");
    end
endmodule
