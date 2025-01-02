class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction);
  function new(string path="trans");
    super.new(path);
  endfunction
  
  rand bit[9:0]addr;
  rand bit[7:0]data;
  rand bit wr;
  rand bit cs;
  bit [7:0]out;
endclass
