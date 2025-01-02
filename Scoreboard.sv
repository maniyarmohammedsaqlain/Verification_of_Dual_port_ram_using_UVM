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
