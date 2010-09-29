require 'todee/todee_decompiler'
require 'todee/todee_code_utils'

include CodeDSL

describe TodeeDecompiler, "decompiling a code matrix" do
  before do
    @decompiler = TodeeDecompiler.new
  end
  
  it "should decompile a single MOV instruction" do
    matrix = [[ MOV(1.ref, 2.ref.ref) ]]
    text = @decompiler.decompile_matrix(matrix)
    text.should == <<EOF
MOV %1, %%2
EOF
  end
  
  it "should decompile a single ADD instruction" do
    matrix = [[ ADD(1.ref.ref, 2, 3.ref) ]]
    text = @decompiler.decompile_matrix(matrix)
    text.should == <<EOF
ADD %%1, 2, %3
EOF
  end

  it "should decompile a single STP instruction" do
    matrix = [[ STP() ]]
    text = @decompiler.decompile_matrix(matrix)
    text.should == <<EOF
STP
EOF
  end

  
  it "should decompile a single NOP instruction" do
    matrix = [[ NOP() ]]
    text = @decompiler.decompile_matrix(matrix)
    text.should == <<EOF
.
EOF
  end
  
  it "should decompile static TUR instructions to readable alias" do
    @decompiler.decompile_matrix([[ TUR(0) ]]).should == "|v|\n"
    @decompiler.decompile_matrix([[ TUR(1) ]]).should == "|>|\n"
    @decompiler.decompile_matrix([[ TUR(2) ]]).should == "|^|\n"
    @decompiler.decompile_matrix([[ TUR(3) ]]).should == "|<|\n"
    
    @decompiler.decompile_matrix([[ TUR(4) ]]).should == "TUR 4\n"
    @decompiler.decompile_matrix([[ TUR(1.ref) ]]).should == "TUR %1\n"
  end  
  
  it "should decompile four instructions on a row" do
    matrix = [[ NOP(), ADD(1.ref, 2.ref, 3), MOV(4.ref, 1.ref), STP() ]]
    text = @decompiler.decompile_matrix(matrix)
    text.should == <<EOF
.\tADD %1, %2, 3\tMOV %4, %1\tSTP
EOF
  end

  it "should decompile two rows of instructions" do
    matrix = [  [ ADD(1.ref, 2.ref, 3), MOV(4.ref, 1.ref) ],
                [ TUR(3), TUR(1) ]]
    text = @decompiler.decompile_matrix(matrix)
    text.should == <<EOF
ADD %1, %2, 3\tMOV %4, %1
|<|\t|>|
EOF
  end
end
