class Instruction
  def int(value)
    (value or 0).to_i
  end
end

class NOPInstruction < Instruction
  def execute(context, dummy1, dummy2)
    nil
  end
  
  def takes_target() false; end
  def num_args() 0; end
end

class STPInstruction < Instruction
  def execute(context, dummy1, dummy2)
    context.stop()
  end
  
  def takes_target() false; end
  def num_args() 0; end
end

class TURInstruction < Instruction
  def execute(context, value, dummy)
    context.turn_to(value % 4)
  end

  def takes_target() false; end
  def num_args() 1; end
end

class TNRInstruction < Instruction
  def execute(context, value, dummy)
    context.turn_right() if value and value != 0
  end
  
  def takes_target() false; end
  def num_args() 1; end
end

class TNLInstruction < Instruction
  def execute(context, value, dummy)
    context.turn_left() if value and value != 0
  end

  def takes_target() false; end
  def num_args() 1; end
end

class JMPInstruction < Instruction
  def execute(context, value, dummy)
    context.jump(int(value))
  end

  def takes_target() false; end
  def num_args() 1; end
end

class CALInstruction < Instruction
  def execute(context, value, dummy)
    context.call_jump(int(value))
  end

  def takes_target() false; end
  def num_args() 1; end
end

class RETInstruction < Instruction
  def execute(context, dummy1, dummy2)
    context.return_jump()
  end

  def takes_target() false; end
  def num_args() 0; end
end

class DRPInstruction < Instruction
  def execute(context, dummy1, dummy2)
    context.drop_call()
  end

  def takes_target() false; end
  def num_args() 0; end
end

class ADDInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) + int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class SUBInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) - int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class MULInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) * int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class DIVInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) / int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class REMInstruction < Instruction
  def execute(context, value1, value2)
    int(value1).remainder(int(value2))
  end

  def takes_target() true; end
  def num_args() 2; end
end

class NEGInstruction < Instruction
  def execute(context, value, dummy)
    -int(value)
  end

  def takes_target() true; end
  def num_args() 1; end
end

class MOVInstruction < Instruction
  def execute(context, value, dummy)
    int(value)
  end

  def takes_target() true; end
  def num_args() 1; end
end

class ANDInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) & int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class ORInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) | int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class XORInstruction < Instruction
  def execute(context, value1, value2)
    int(value1) ^ int(value2)
  end

  def takes_target() true; end
  def num_args() 2; end
end

class NOTInstruction < Instruction
  def execute(context, value, dummy)
    ~int(value)
  end

  def takes_target() true; end
  def num_args() 1; end
end

class EQInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) == int(value2) then 1 else 0 end
  end

  def takes_target() true; end
  def num_args() 2; end
end

class NEQInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) != int(value2) then 1 else 0 end
  end

  def takes_target() true; end
  def num_args() 2; end
end

class LTInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) < int(value2) then 1 else 0 end
  end

  def takes_target() true; end
  def num_args() 2; end
end

class GTInstruction < Instruction
  def execute(context, value1, value2)
    if int(value1) > int(value2) then 1 else 0 end
  end

  def takes_target() true; end
  def num_args() 2; end
end
