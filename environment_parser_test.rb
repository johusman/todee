require 'todee_environment_parser'
require 'todee_sockets'

describe TodeeEnvironmentParser, "parsing environment file" do
  before do
    @parser = TodeeEnvironmentParser.new
  end
  
  it "should parse a simple environment" do
    string = <<EOF
TodeeEnvironment:
  0: Memory
EOF
    env = @parser.parse_file(string)
    env.sockets.size.should == 1
    env.sockets[0].is_a?(MemorySocket).should == true
  end
  
  it "should parse a larger environment" do
    string = <<EOF
TodeeEnvironment:
  0: Stdout
  1: Stack
  2: Memory
EOF
    env = @parser.parse_file(string)
    env.sockets.size.should == 3
    env.sockets[0].is_a?(StdoutSocket).should == true
    env.sockets[1].is_a?(StackSocket).should == true
    env.sockets[2].is_a?(MemorySocket).should == true
  end  
end