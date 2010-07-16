require 'todee_sockets'
require 'todee_environment'

describe TodeeEnvironment, "handling registration of sockets" do
  before do
    @environment = TodeeEnvironment.new
  end
  
  it "should answer requests for sockets at unregistered addresses with a NullSocket" do
    @environment.socket(0).should be_an_instance_of(NullSocket)
  end
  
  it "should return registered sockets on specific addresses" do
    @environment.socket(2).should be_an_instance_of(NullSocket)
    @environment.register_socket(MemorySocket.new, 2)
    @environment.socket(2).should be_an_instance_of(MemorySocket)
  end
end

describe TodeeEnvironment, "handling socket communication" do
  before do
    @environment = TodeeEnvironment.new
    @memory_socket = MemorySocket.new
    @stack_socket = StackSocket.new
    @environment.register_socket(@memory_socket, 0)
    @environment.register_socket(@stack_socket, 1)
  end
  
  it "should write to the correct socket" do
    @environment.write(0, 123)
    @environment.write(1, 345)
    @memory_socket.read.should == 123
    @stack_socket.read.should == 345
  end
  
  it "should read from the correct socket" do
    @memory_socket.write(567)
    @stack_socket.write(789)
    @environment.read(0).should == 567
    @environment.read(1).should == 789
  end

  it "should alias write with []=" do
    @environment[0] = 123
    @environment[1] = 345
    @memory_socket.read.should == 123
    @stack_socket.read.should == 345
  end  
  
  it "should alias read with []" do
    @memory_socket.write(567)
    @stack_socket.write(789)
    @environment[0].should == 567
    @environment[1].should == 789
  end
end