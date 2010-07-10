require 'todee_sockets'

describe SocketManager, "handling registration of sockets" do
  before do
    @manager = SocketManager.new
  end
  
  it "should answer requests for sockets at unregistered addresses with a NullSocket" do
    @manager.socket(0).should be_an_instance_of(NullSocket)
  end
  
  it "should return registered sockets on specific addresses" do
    @manager.socket(2).should be_an_instance_of(NullSocket)
    @manager.register_socket(MemorySocket.new, 2)
    @manager.socket(2).should be_an_instance_of(MemorySocket)
  end
end

describe SocketManager, "handling socket communication" do
  before do
    @manager = SocketManager.new
    @memory_socket = MemorySocket.new
    @stack_socket = StackSocket.new
    @manager.register_socket(@memory_socket, 0)
    @manager.register_socket(@stack_socket, 1)
  end
  
  it "should write to the correct socket" do
    @manager.write(0, 123)
    @manager.write(1, 345)
    @memory_socket.read.should == 123
    @stack_socket.read.should == 345
  end
  
  it "should read from the correct socket" do
    @memory_socket.write(567)
    @stack_socket.write(789)
    @manager.read(0).should == 567
    @manager.read(1).should == 789
  end

  it "should alias write with []=" do
    @manager[0] = 123
    @manager[1] = 345
    @memory_socket.read.should == 123
    @stack_socket.read.should == 345
  end  
  
  it "should alias read with []" do
    @memory_socket.write(567)
    @stack_socket.write(789)
    @manager[0].should == 567
    @manager[1].should == 789
  end
end