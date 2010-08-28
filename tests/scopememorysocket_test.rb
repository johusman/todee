require 'todee/todee_sockets'

describe ScopeMemorySocket, "behaves like MemorySocket" do
  before do
    @memory = ScopeMemorySocket.new
  end

  it "should return nil when uninitialized" do
    @memory.read.should == nil
  end
  
  it "should retain value" do
    @memory.write(14)
    @memory.read.should == 14
    @memory.write(22)
    @memory.read.should == 22
    @memory.read.should == 22
  end
end

describe ScopeMemorySocket, "behaves like MemorySocket" do
  before do
    @memory = ScopeMemorySocket.new
  end

  it "should retain current value when call is pushed" do
    @memory.write(14)
    @memory.push_call()
    @memory.read.should == 14
  end
  
  it "should recall old value when call is popped" do
    @memory.write(14)
    @memory.push_call()
    @memory.write(22)
    @memory.read.should == 22
    @memory.pop_call()
    @memory.read.should == 14
  end
  
  it "should not affect value when popping without push" do
    @memory.write(14)
    @memory.pop_call()
    @memory.read.should == 14
  end
end
