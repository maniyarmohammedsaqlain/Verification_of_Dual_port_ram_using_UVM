class sequence1 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence1);
  transaction trans;
  function new(string path="seq");
    super.new(path);
  endfunction
  
  virtual task body();
    
    repeat(10)
      begin
        trans=transaction::type_id::create("trans");
        start_item(trans);
        trans.randomize();
        `uvm_info("seq",$sformatf("ADDR: %0d DATA: %0d WR:%0d CS:%0d",trans.addr,trans.data,trans.wr,trans.cs),UVM_NONE);
        finish_item(trans);
      end
  endtask
endclass
