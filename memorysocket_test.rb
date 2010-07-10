require 'todee_sockets'

describe MemorySocket, "stores one value" do
  before do
    @memory = MemorySocket.new
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