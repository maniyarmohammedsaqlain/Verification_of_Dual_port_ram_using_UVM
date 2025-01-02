class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  transaction trans;
  virtual inter inf;
  uvm_analysis_port #(transaction) send;
  function new(string path="mon",uvm_component parent=null);
    super.new(path,parent);
    send=new("send",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans=transaction::type_id::create("trans",this);
    if(!uvm_config_db #(virtual inter)::get(this,"","inf",inf))
      `uvm_info("mon","error in configdb of mon",UVM_NONE);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever
      begin
        #20;
        trans.addr=inf.addr;
        trans.data=inf.data;
        trans.cs=inf.cs;
        trans.wr=inf.wr;
        trans.out=inf.out;
        `uvm_info("MON",$sformatf("ADDR: %0d DATA: %0d WR:%0d CS:%0d OUT=%0d",trans.addr,trans.data,trans.wr,trans.cs,trans.out),UVM_NONE);
        send.write(trans);
      end
  endtask
endclass
