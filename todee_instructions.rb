class Address < Fixnum
end

class Instruction
  def int(value)
    (value or 0).to_i
  end
end

class NOPInstruction
  def execute(context, dummy1, dummy2)
    nil
  end
end

class STPInstruction
  def execute(context, dummy1, dummy2)
    context.stop()
  end
end

class TURInstruction < Instruction
  def execute(context, value, dummy)
    context.turn_to(value)
  end
end

class TPLUSCInstruction < Instruction
  def execute(context, value, dummy)
    context.turn_right() if value and value != 0
  end
end

class TMINUSCInstruction < Instruction
  def execute(context, value, dummy)
    context.turn_left() if value and value != 0
  end
end

class ADDInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) + int(value2)
  end
end

class SUBInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) - int(value2)
  end
end

class MULInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) * int(value2)
  end
end

class DIVInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) / int(value2)
  end
end

class NEGInstruction < Instruction
  def execute(context, value, dummy)
    -int(value)
  end
end

class MOVInstruction < Instruction
  def execute(context, value, dummy)
    int(value)
  end
end

class ANDInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) & int(value2)
  end
end

class ORInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) | int(value2)
  end
end

class XORInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) ^ int(value2)
  end
end

class NOTInstruction < Instruction
  def execute(context, value, dummy)
    ~int(value)
  end
end

class EQInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) == int(value2) then 1 else 0 end
  end
end

class NEQInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) != int(value2) then 1 else 0 end
  end
end

class LTInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) < int(value2) then 1 else 0 end
  end
end

class GTInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) > int(value2) then 1 else 0 end
  end
end