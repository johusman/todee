class CodePoint
  attr_reader :instruction_symbol, :target, :arguments
  attr_writer :instruction_symbol, :target, :arguments
  
  def initialize(instruction_symbol, target, arguments)
    @instruction_symbol = instruction_symbol
    @target = target
    @arguments = arguments
  end
  
  def to_s()
    arg_str = arguments.map { |value| if value then value.to_s else '_' end }.join(" ")
    "<#{@instruction_symbol} #{@target.to_s if @target.to_s} #{arg_str}>"
  end
  
  def copy()
    return CodePoint.new(@instruction_symbol, @target ? @target.clone() : nil, @arguments.map {|arg| arg.clone()})
  end
  
  NOP = CodePoint.new(:NOP, nil, [])
end

class Argument
  attr_reader :value, :ref_level
  
  def initialize(value, ref_level)
    @value = value
    @ref_level = ref_level
  end
  
  def to_s()
    "#{'%' * @ref_level}#{value}"
  end
end

