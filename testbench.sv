`include "uvm_macros.svh";
import uvm_pkg::*;

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

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);

  transaction trans;
  uvm_analysis_imp #(transaction, scoreboard) recv;

  reg [7:0] mem [1023:0];

  function new(string path="scb", uvm_component parent=null);
    super.new(path, parent);
    recv = new("recv", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans = transaction::type_id::create("trans");
    
    for (int i = 0; i < 1024; i++) begin
      mem[i] = 0;
    end
  endfunction

  virtual function void write(transaction tra);
    trans = tra;

    if (trans.wr && trans.cs) begin
      mem[trans.addr] = trans.data;
      `uvm_info("MEMORY_UPDATE", $sformatf("Memory updated at addr: %0d with data: %0d", 
                  trans.addr, trans.data), UVM_LOW);
    end

    if ((!trans.wr && !trans.cs) && (trans.out == mem[trans.addr])) begin
      `uvm_info("SCB", "WRITE and CS SIGNAL LOW, NO MEMORY MODIFICATION", UVM_NONE);
      `uvm_info("FINISH","------------------------------------------------------------------------------------------",UVM_NONE);
    end
    else if ((!trans.wr && trans.cs) && (trans.out == mem[trans.addr])) begin
      `uvm_info("SCB", "WRITE SIGNAL LOW, NO MEMORY MODIFICATION", UVM_NONE);
      `uvm_info("FINISH","------------------------------------------------------------------------------------------",UVM_NONE);
    end
    else if ((trans.wr && !trans.cs) && (trans.out == mem[trans.addr])) begin
      `uvm_info("SCB", "CS SIGNAL LOW, NO MEMORY MODIFICATION", UVM_NONE);
      `uvm_info("FINISH","------------------------------------------------------------------------------------------",UVM_NONE);
    end
    else if ((trans.wr && trans.cs) && (trans.out == mem[trans.addr])) begin
      `uvm_info("SCB", "DATA STORED IN MEMORY, MEMORY PASS", UVM_NONE);
      `uvm_info("FINISH","------------------------------------------------------------------------------------------",UVM_NONE);
    end
    else begin
      `uvm_info("SCB", "Memory verification failed!",UVM_NONE);
      `uvm_info("FINISH","------------------------------------------------------------------------------------------",UVM_NONE);
    end
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent);
  driver drv;
  monitor mon;
  uvm_sequencer #(transaction)seqr;
  function new(string path="a",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv=driver::type_id::create("drv",this);
    mon=monitor::type_id::create("mon",this);
    seqr=uvm_sequencer#(transaction)::type_id::create("seqr",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);
  scoreboard scb;
  agent a;
  function new(string path="env",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb=scoreboard::type_id::create("scb",this);
    a=agent::type_id::create("a",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.mon.send.connect(scb.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);
  env e;
  sequence1 s;
  
  function new(string path="test",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e=env::type_id::create("e",this);
    s=sequence1::type_id::create("s",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s.start(e.a.seqr);
    #50;
    phase.drop_objection(this);
  endtask
endclass

module tb;
  inter inf();
  dual_port_ram DUT(.data(inf.data),.addr(inf.addr),.out(inf.out),.wr(inf.wr),.cs(inf.cs));
  
  initial
    begin
      uvm_config_db #(virtual inter)::set(null,"*","inf",inf);
      run_test("test");
    end
endmodule
  
  
  
        

        
    
    
    
    
    
  
  
