class CodePoint
  attr_reader :instruction_symbol, :reference, :arguments
  
  def initialize(instruction_symbol, reference, arguments)
    @instruction_symbol = instruction_symbol
    @reference = reference
    @arguments = arguments
  end
  
  def to_s()
    arg_str = arguments.map { |value| if value then value.to_s else '_' end }.join(" ")
    "<#{@instruction_symbol} #{if @reference then @reference.to_s else '_' end } #{arg_str}>"
  end
end

class Argument
  attr_reader :value
  
  def initialize(value, is_ref)
    @value = value
    @is_ref = is_ref
  end
  
  def is_ref?()
    return @is_ref
  end
  
  def to_s()
    if @is_ref then "&#{value}" else "#{value}" end
  end
end

