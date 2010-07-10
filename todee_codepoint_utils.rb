require 'todee_codepoint'

def internal_handle_args(args)
  args.map do |arg|
    if not arg.instance_of?(Argument)
      arg = arg[0] if arg.instance_of?(String)
      Argument.new(arg, false)
    else
      arg
    end
  end
end

def internal_construct_codepoint(op, dest, args)
  CodePoint.new(op, dest, internal_handle_args(args))
end

class Fixnum
  def ref()
    Argument.new(self, true)
  end
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

def STP()
  internal_construct_codepoint(:STP, nil, [])
end

def NOP()
  internal_construct_codepoint(:NOP, nil, [])
end
