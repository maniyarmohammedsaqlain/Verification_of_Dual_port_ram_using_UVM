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
