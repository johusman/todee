require 'todee_instructions'

describe Instruction, "various instructions" do
  it "should handle ADD" do
    ADDInstruction.new.execute(nil, 5, 8).should == 13
    ADDInstruction.new.execute(nil, 5, nil).should == 5
  end
  
  it "should handle SUB" do
    SUBInstruction.new.execute(nil, 5, 8).should == -3
    SUBInstruction.new.execute(nil, 5, nil).should == 5
  end
  
  it "should handle MUL" do
    MULInstruction.new.execute(nil, 5, 8).should == 40
    MULInstruction.new.execute(nil, 5, nil).should == 0
  end

  it "should handle DIV" do
    DIVInstruction.new.execute(nil, 35, 7).should == 5
    DIVInstruction.new.execute(nil, nil, 8).should == 0
  end

  it "should handle NEG" do
    NEGInstruction.new.execute(nil, 4, nil).should == -4
    NEGInstruction.new.execute(nil, nil, nil).should == 0
  end
  
  it "should handle MOV" do
    MOVInstruction.new.execute(nil, 7, nil).should == 7
    MOVInstruction.new.execute(nil, nil, nil).should == 0
  end

  it "should handle AND" do
    ANDInstruction.new.execute(nil, 3, 6).should == 2
    ANDInstruction.new.execute(nil, nil, nil).should == 0
  end
  
  it "should handle OR" do
    ORInstruction.new.execute(nil, 3, 6).should == 7
    ORInstruction.new.execute(nil, nil, nil).should == 0
  end
  
  it "should handle XOR" do
    XORInstruction.new.execute(nil, 3, 6).should == 5
    XORInstruction.new.execute(nil, nil, nil).should == 0
  end

  it "should handle NOT" do
    NOTInstruction.new.execute(nil, 3, nil).should == -4
    NOTInstruction.new.execute(nil, nil, nil).should == -1
  end
  
  it "should handle EQ" do
    EQInstruction.new.execute(nil, 3, 4).should == 0
    EQInstruction.new.execute(nil, 4, 4).should == 1
    EQInstruction.new.execute(nil, nil, 0).should == 1
  end
  
  it "should handle NEQ" do
    NEQInstruction.new.execute(nil, 3, 4).should == 1
    NEQInstruction.new.execute(nil, 4, 4).should == 0
    NEQInstruction.new.execute(nil, nil, 0).should == 0
  end
  
  it "should handle GT" do
    GTInstruction.new.execute(nil, 3, 4).should == 0
    GTInstruction.new.execute(nil, 4, 3).should == 1
    GTInstruction.new.execute(nil, 4, 4).should == 0
    GTInstruction.new.execute(nil, nil, 1).should == 0
    GTInstruction.new.execute(nil, 1, nil).should == 1
    GTInstruction.new.execute(nil, nil, nil).should == 0
  end
  
  it "should handle LT" do
    LTInstruction.new.execute(nil, 4, 3).should == 0
    LTInstruction.new.execute(nil, 3, 4).should == 1
    LTInstruction.new.execute(nil, 4, 4).should == 0
    LTInstruction.new.execute(nil, 1, nil).should == 0
    LTInstruction.new.execute(nil, nil, 1).should == 1
    LTInstruction.new.execute(nil, nil, nil).should == 0
  end
  
  it "should handle STP" do
    context_mock = mock("context")
    context_mock.should_receive(:stop)
    STPInstruction.new.execute(context_mock, nil, nil)
  end

  it "should handle TUR" do
    context_mock = mock("context")
    context_mock.should_receive(:turn_to).with(1)
    TURInstruction.new.execute(context_mock, 1, nil)
  end
  
  it "should handle TNR" do
    context_mock = mock("context when true")
    context_mock.should_receive(:turn_right)
    TNRInstruction.new.execute(context_mock, 1, nil)
    context_mock = mock("context when false")
    context_mock.should_not_receive(:turn_right)
    TNRInstruction.new.execute(context_mock, 0, nil)
  end
  
  it "should handle TNL" do
    context_mock = mock("context when true")
    context_mock.should_receive(:turn_left)
    TNLInstruction.new.execute(context_mock, 1, nil)
    context_mock = mock("context when false")
    context_mock.should_not_receive(:turn_left)
    TNLInstruction.new.execute(context_mock, 0, nil)
  end
end