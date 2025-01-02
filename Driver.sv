class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver);
  transaction trans;
  virtual inter inf;
  function new(string path="drv",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans=transaction::type_id::create("trans",this);
    if(!uvm_config_db #(virtual inter)::get(this,"","inf",inf))
      `uvm_info("drv","error in configdb of driver",UVM_NONE);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever
      begin
        seq_item_port.get_next_item(trans);
        inf.addr<=trans.addr;
        inf.data<=trans.data;
        inf.cs<=trans.cs;
        inf.wr<=trans.cs;
        `uvm_info("DRV",$sformatf("DRIVER DATA IS ADDR: %0d DATA: %0d WR:%0d CS:%0d",trans.addr,trans.data,trans.wr,trans.cs),UVM_NONE);
        seq_item_port.item_done(trans);
        #20;
      end
  endtask
endclass
