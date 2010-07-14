require 'todee_context_parser'
require 'todee_sockets'

describe TodeeContextParser, "parsing context file" do
  before do
    @parser = TodeeContextParser.new
  end
  
  it "should parse a simple context" do
    string = <<EOF
Context:
  0: Memory
EOF
    context = @parser.parse_file(string)
    context.sockets.size.should == 1
    context.sockets[0].is_a?(MemorySocket).should == true
  end
  
  it "should parse a larger context" do
    string = <<EOF
Context:
  0: Stdout
  1: Stack
  2: Memory
EOF
    context = @parser.parse_file(string)
    context.sockets.size.should == 3
    context.sockets[0].is_a?(StdoutSocket).should == true
    context.sockets[1].is_a?(StackSocket).should == true
    context.sockets[2].is_a?(MemorySocket).should == true
  end  
end