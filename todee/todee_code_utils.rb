require 'todee/todee_codepoint'
require 'todee/todee_instructions'


module CodeUtils
  @@known_instructions = {}
  
  def get_instruction(symbol)
    return @@known_instructions[symbol] if @@known_instructions[symbol]
    
    instruction_class = Kernel::const_get("#{symbol.to_s}Instruction")
    
    if instruction_class.ancestors.include?(Instruction) then
      instruction = instruction_class.new()
      @@known_instructions[symbol] = instruction
      return instruction
    else
      return nil
    end
  end
end

module CodeDSL

  class ::Fixnum
    def ref()
      Argument.new(self, 1)
    end
  end
  
  class ::Argument
    def ref()
      Argument.new(self.value, self.ref_level + 1)
    end
  end

  
  def internal_handle_args(args)
    args.map do |arg|
      internal_handle_arg(arg)
    end
  end
  
  def internal_handle_arg(arg)
    return nil if arg == nil
    if not arg.instance_of?(Argument)
      arg = arg[0] if arg.instance_of?(String)
      Argument.new(arg, 0)
    else
      arg
    end
  end

  def internal_construct_codepoint(op, dest, args)
    CodePoint.new(op, internal_handle_arg(dest), internal_handle_args(args))
  end

  def TUR(*args)
    internal_construct_codepoint(:TUR, nil, args)
  end

  def TNR(*args)
    internal_construct_codepoint(:TNR, nil, args)
  end

  def TNL(*args)
    internal_construct_codepoint(:TNL, nil, args)
  end

  def STP()
    internal_construct_codepoint(:STP, nil, [])
  end

  def NOP()
    internal_construct_codepoint(:NOP, nil, [])
  end

  def JMP(*args)
    internal_construct_codepoint(:JMP, nil, args)
  end

  def CAL(*args)
    internal_construct_codepoint(:CAL, nil, args)
  end

  def RET()
    internal_construct_codepoint(:RET, nil, [])
  end

  def DRP()
    internal_construct_codepoint(:DRP, nil, [])
  end
  
  def ADD(dest, *args)
    internal_construct_codepoint(:ADD, dest, args)
  end

  def SUB(dest, *args)
    internal_construct_codepoint(:SUB, dest, args)
  end

  def MUL(dest, *args)
    internal_construct_codepoint(:MUL, dest, args)
  end

  def DIV(dest, *args)
    internal_construct_codepoint(:DIV, dest, args)
  end

  def REM(dest, *args)
    internal_construct_codepoint(:REM, dest, args)
  end  
  
  def NEG(dest, *args)
    internal_construct_codepoint(:NEG, dest, args)
  end

  def MOV(dest, *args)
    internal_construct_codepoint(:MOV, dest, args)
  end

  def AND(dest, *args)
    internal_construct_codepoint(:AND, dest, args)
  end

  def OR(dest, *args)
    internal_construct_codepoint(:OR, dest, args)
  end

  def XOR(dest, *args)
    internal_construct_codepoint(:XOR, dest, args)
  end

  def NOT(dest, *args)
    internal_construct_codepoint(:NOT, dest, args)
  end

  def EQ(dest, *args)
    internal_construct_codepoint(:EQ, dest, args)
  end

  def NEQ(dest, *args)
    internal_construct_codepoint(:NEQ, dest, args)
  end

  def LT(dest, *args)
    internal_construct_codepoint(:LT, dest, args)
  end

  def GT(dest, *args)
    internal_construct_codepoint(:GT, dest, args)
  end
end