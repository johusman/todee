require 'todee/todee_parser'

describe TodeeParser, "parsing normal single code points" do
  before do
    @parser = TodeeParser.new
  end
  
  it "should parse a simple ADD" do
    cp, leftover = @parser.consume_code_point("add %1, 2, 3")
    leftover.should == ""
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [2, 3]
    cp.arguments.map{|arg| arg.ref_level }.should == [0, 0]
  end
  
  it "should parse an ADD with references" do
    cp, leftover = @parser.consume_code_point("add %1, %2, %3")
    leftover.should == ""
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [2, 3]
    cp.arguments.map{|arg| arg.ref_level }.should == [1, 1]
  end
  
  it "should parse an ADD with metareferences" do
    cp, leftover = @parser.consume_code_point("add %%1, %%2, %%3")
    leftover.should == ""
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 2
    cp.arguments.map{|arg| arg.value }.should == [2, 3]
    cp.arguments.map{|arg| arg.ref_level }.should == [2, 2]
  end  
  
  it "should parse character arguments" do
    cp, leftover = @parser.consume_code_point("add %1, 'h', 'j'")
    leftover.should == ""
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [104, 106]
    cp.arguments.map{|arg| arg.ref_level }.should == [0, 0]
  end

  it "should return additional code points as leftovers" do
    cp, leftover = @parser.consume_code_point("add %1, %2, %3 TUR 0")
    leftover.strip.should == "TUR 0"
  end
  
  it "should ignore non-syntax whitespace" do
    cp, leftover = @parser.consume_code_point(" add  %1 ,  %2  , %3 ")
    leftover.strip.should == ""
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [2, 3]
    cp.arguments.map{|arg| arg.ref_level }.should == [1, 1]
  end
  
  it "should manage instructions with no target" do
    cp, leftover = @parser.consume_code_point("TUR 4")
    leftover.strip.should == ""
    cp.instruction_symbol.should == :TUR
    cp.target.should == nil
    cp.arguments.map{|arg| arg.value }.should == [4]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end
  
  it "should parse dot as NOP" do
    cp, leftover = @parser.consume_code_point(".")
    leftover.strip.should == ""
    cp.instruction_symbol.should == :NOP
    cp.target.should == nil
    cp.arguments.size.should == 0
  end
  
  it "should not misinterpret character quoted dot" do
    cp, leftover = @parser.consume_code_point("mov %1, '.'")
    leftover.strip.should == ""
    cp.instruction_symbol.should == :MOV
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [46]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end

  it "should translate alias |^|" do
    cp, leftover = @parser.consume_code_point("|^| NOP")
    leftover.should == "NOP"
    cp.instruction_symbol.should == :TUR
    cp.target.should == nil
    cp.arguments.map{|arg| arg.value }.should == [2]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end  

  it "should translate alias |>|" do
    cp, leftover = @parser.consume_code_point("|>| NOP")
    leftover.should == "NOP"
    cp.instruction_symbol.should == :TUR
    cp.target.should == nil
    cp.arguments.map{|arg| arg.value }.should == [1]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end    

  it "should translate alias |v|" do
    cp, leftover = @parser.consume_code_point("|v| NOP")
    leftover.should == "NOP"
    cp.instruction_symbol.should == :TUR
    cp.target.should == nil
    cp.arguments.map{|arg| arg.value }.should == [0]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end    
  
  it "should translate alias |>|" do
    cp, leftover = @parser.consume_code_point("|<| NOP")
    leftover.should == "NOP"
    cp.instruction_symbol.should == :TUR
    cp.target.should == nil
    cp.arguments.map{|arg| arg.value }.should == [3]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end
  
  it "should treat stars (*) as whitespace" do
    cp, leftover = @parser.consume_code_point("add %1, *%2, %3**TUR*0")
    leftover.strip.should == "TUR 0"
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [2, 3]
    cp.arguments.map{|arg| arg.ref_level }.should == [1, 1]
  end
  
  it "should not misinterpret character quoted star (*)" do
    cp, leftover = @parser.consume_code_point("mov %1, '*'")
    leftover.strip.should == ""
    cp.instruction_symbol.should == :MOV
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [42]
    cp.arguments.map{|arg| arg.ref_level }.should == [0]
  end
  
end

describe TodeeParser, "parsing broken single code points" do
  before do
    @parser = TodeeParser.new
  end
  
  def test_fail()
    lambda { yield() }.should raise_error(TodeeParseException)
  end
  
  it "should fail on too few arguments" do
    test_fail { @parser.consume_code_point("add %1, 2 TUR 0") }
  end

  it "should fail on too many arguments" do
    test_fail { @parser.consume_code_point("add %1, 2, 3, 4 TUR 0") }
  end
  
  it "should fail when target is a reference" do
    test_fail { @parser.consume_code_point("add 1, 2 TUR 0") }
  end

  it "should fail on too many arguments to a target-less instruction" do
    test_fail { @parser.consume_code_point("TUR %1, %2 TUR 0") }
  end
  
  it "should not accept negative references" do
    test_fail { @parser.consume_code_point("MOV %1, %-2 TUR 0") }
  end
  
  it "should bark on missing arguments between commas" do
    test_fail { @parser.consume_code_point("MOV %1,, %2 TUR 0") }
  end  
  
  it "should not accept comma after op code" do
    test_fail { @parser.consume_code_point("MOV, %1, %2 TUR 0") }
  end
  
  it "should fail on misplaced dots" do
    test_fail { @parser.consume_code_point("MOV ., %3, %1") }
    test_fail { @parser.consume_code_point("MOV .") }
  end  
end

describe TodeeParser, "parsing whole line" do
  before do
    @parser = TodeeParser.new
  end
  
  it "should parse two simple code points" do
    cp1, cp2 = @parser.parse_code_points("add %%1, 2, 3\tmov %4, %1")
    
    cp1.instruction_symbol.should == :ADD
    cp1.target.value.should == 1
    cp1.target.ref_level.should == 2
    cp1.arguments.map{|arg| arg.value }.should == [2, 3]
    cp1.arguments.map{|arg| arg.ref_level }.should == [0, 0]
    
    cp2.instruction_symbol.should == :MOV
    cp2.target.value.should == 4
    cp2.target.ref_level.should == 1
    cp2.arguments.map{|arg| arg.value }.should == [1]
    cp2.arguments.map{|arg| arg.ref_level }.should == [1]
  end
  
  it "should not be confused by dots" do
    cp0, cp1, cp2 = @parser.parse_code_points(".\tadd %%1, 2, 3\tmov %4, %1")

    cp0.instruction_symbol.should == :NOP

    cp1.instruction_symbol.should == :ADD
    cp1.target.value.should == 1
    cp1.target.ref_level.should == 2
    cp1.arguments.map{|arg| arg.value }.should == [2, 3]
    cp1.arguments.map{|arg| arg.ref_level }.should == [0, 0]
    
    cp2.instruction_symbol.should == :MOV
    cp2.target.value.should == 4
    cp2.target.ref_level.should == 1
    cp2.arguments.map{|arg| arg.value }.should == [1]
    cp2.arguments.map{|arg| arg.ref_level }.should == [1]
  end  
  
  it "should ignore comments" do
    cps = @parser.parse_code_points("add %1, 2, 3 # add some stuff")
    cps.size.should == 1
    cp = cps[0]
    
    cp.instruction_symbol.should == :ADD
    cp.target.value.should == 1
    cp.target.ref_level.should == 1
    cp.arguments.map{|arg| arg.value }.should == [2, 3]
    cp.arguments.map{|arg| arg.ref_level }.should == [0, 0]
    
    @parser.parse_code_points("# just a comment").size.should == 0
  end
end

describe TodeeParser, "parsing whole file" do
  before do
    @parser = TodeeParser.new
  end
  
  it "should parse hello world" do
    file = <<EOF
      # A rather stupid Hello World program, provided the following environment:
      #  0 = stdout
      #  1 = stack socket
      #  2 = memory socket
      mov %1, 10      # Single line feed for unix systems
      mov %1, '!'
      mov %1, 'o'
      mov %1, 'l'
      mov %1, 'l'
      mov %1, 'e'
      mov %1, 'h'
      TUR 0           TNL 1
      mov %2, %1      mov %0, %2
      TNL %2          TNL 1
      STP
EOF
    
    matrix = @parser.parse_file(file)
    matrix.size.should == 11
    matrix.each { |row| row.size.should == 2 }
  end
end
