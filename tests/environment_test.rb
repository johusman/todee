require 'todee/todee_sockets'
require 'todee/todee_environment'

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

describe TodeeEnvironment, "dereferencing arguments" do
  before do
    @environment = TodeeEnvironment.new
    @environment.register_socket(MemorySocket.new, 0)
    @environment.register_socket(MemorySocket.new, 1)
    @environment.register_socket(MemorySocket.new, 2)
    @environment.register_socket(MemorySocket.new, 3)
    
    @environment.write(0, 13)
    @environment.write(1, 37)
    @environment.write(2, 71)
    @environment.write(3, 1)
  end
  
  it "should pass constants right through when reading" do
    @environment.deref_read(44, 0).should == 44
  end
  
  it "should dereference one level when reading" do
    @environment.deref_read(2, 1).should == 71
  end
  
  it "should dereference two levels when reading" do
    @environment.deref_read(3, 2).should == 37
  end
  
  it "should dereference undefined addresses as if they referred to 0 when reading" do
    @environment.deref_read(5, 1).should == 0
    @environment.deref_read(5, 2).should == 13 # cause we get %%5 -> %0 -> 31
  end

  it "should ignore constants when writing" do
    @environment.deref_write(44, 0, 9999)
    [0, 1, 2, 3].map {|x| @environment.read(x)}.should == [13, 37, 71, 1]
  end
  
  it "should dereference one level when writing" do
    @environment.deref_write(2, 1, 9999)
    [0, 1, 2, 3].map {|x| @environment.read(x)}.should == [13, 37, 9999, 1]
  end
  
  it "should dereference two levels when writing" do
    @environment.deref_write(3, 2, 9999)
    [0, 1, 2, 3].map {|x| @environment.read(x)}.should == [13, 9999, 71, 1]
  end
  
  it "should ignore undefined addresses when writing" do
    @environment.deref_write(5, 1, 9999)
    [0, 1, 2, 3].map {|x| @environment.read(x)}.should == [13, 37, 71, 1]
    @environment.deref_write(5, 2, 9999)
    [0, 1, 2, 3].map {|x| @environment.read(x)}.should == [13, 37, 71, 1]
  end
end

describe TodeeEnvironment, "handling call push and pop" do
  before do
    @environment = TodeeEnvironment.new
    @environment.register_socket(MemorySocket.new, 0)
    @environment.register_socket(ScopeMemorySocket.new, 1)
  end
  
  it "should handle call push and pop for sockets that support that" do
    @environment.write(0, 15)
    @environment.write(1, 23)
    @environment.push_call()
    @environment.read(0).should == 15
    @environment.read(1).should == 23
    
    @environment.write(1, 41)
    @environment.read(1).should == 41
    
    @environment.pop_call()
    @environment.read(0).should == 15
    @environment.read(1).should == 23
  end
  
  it "should handle call drop" do
    @environment.write(0, 15)
    @environment.write(1, 23)
    @environment.push_call()
    @environment.read(0).should == 15
    @environment.read(1).should == 23
    
    @environment.write(1, 41)
    @environment.read(1).should == 41
    
    @environment.drop_call()
    @environment.read(0).should == 15
    @environment.read(1).should == 41
    
    @environment.pop_call()
    @environment.read(0).should == 15
    @environment.read(1).should == 41
  end
end
