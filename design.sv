module dual_port_ram (out, data, addr, wr, cs);
  parameter addr_size = 10, word_size = 8,memory_size = 1024;
  input [addr_size-1:0] addr;
  input [word_size-1:0] data;
  input wr, cs;
  output [word_size-1:0] out;
  reg [word_size-1:0] mem [memory_size-1:0];
  assign out = mem[addr];
  always @(wr or cs)
    if (wr && cs)
      mem[addr] = data;
endmodule

interface inter;
  logic [9:0]addr;
  logic [7:0]data;
  logic wr;
  logic cs;
  logic [7:0]out;
endinterface
