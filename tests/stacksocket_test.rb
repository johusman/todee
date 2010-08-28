require 'todee/todee_sockets'

describe StackSocket, "acting like stack" do
  before do
    @stack = StackSocket.new
  end

  it "should return nil when uninitialized" do
    @stack.read.should == nil
  end
  
  it "should return the last thing put on the stack" do
    @stack.write(22)
    @stack.read.should == 22
  end
  
  it "should remove values when read" do
    @stack.write(12)
    @stack.read
    @stack.read.should == nil
  end
  
  it "should remember multiple values" do
    @stack.write(4)
    @stack.write(5)
    @stack.write(6)
    @stack.read.should == 6
    @stack.read.should == 5
    @stack.read.should == 4
  end
end
