require 'todee_instructions'

class Context
  attr_reader :instruction_pointer, :stopped, :bounds
  
  def initialize(bounds)
    @instruction_pointer = [0, 0] # row, column
    @direction = [1, 0] # row, column
    @stopped = false
    @bounds = bounds
    
    @directions = [[1, 0], [0, 1], [-1, 0], [0, -1]] # row, column
  end
  
  def turn_to(direction)
    new_dir = @directions[direction]
    if new_dir
      @direction = new_dir
    end
  end
  
  def turn_left()
    @direction = [ -@direction[1], @direction[0] ]
  end
  
  def turn_right()
    @direction = [ @direction[1], -@direction[0] ]
  end
  
  def stop()
    @stopped = true
  end
  
  def advance()
    advance_one_dimension(0)
    advance_one_dimension(1)
    #puts "Now at row #{@instruction_pointer[0]}, col #{@instruction_pointer[1]} with bounds rows #{@bounds[0]}, cols #{@bounds[1]}"
  end
  
  def reset()
    @instruction_pointer = [0, 0]
    @direction = [1, 0]
  end

private

  def advance_one_dimension(dim)
    @instruction_pointer[dim] += @direction[dim]
    if @instruction_pointer[dim] >= @bounds[dim] then
      @instruction_pointer[dim] -= @bounds[dim]
    elsif @instruction_pointer[dim] < 0 then
      @instruction_pointer[dim] += @bounds[dim]
    end
  end
end

class Engine
  def initialize(socket_manager)
    @socket_manager = socket_manager
    @instructions = { :TUR => TURInstruction.new, :TNR => TPLUSCInstruction.new, :TNL => TMINUSCInstruction.new,
                      :ADD => ADDInstruction.new, :SUB => SUBInstruction.new, :MUL => MULInstruction.new,
                      :DIV => DIVInstruction.new, :NEG => NEGInstruction.new, :MOV => MOVInstruction.new,
                      :AND => ANDInstruction.new, :OR => ORInstruction.new, :XOR => XORInstruction.new,
                      :NOT => NOTInstruction.new, :EQ => EQInstruction.new, :NEQ => NEQInstruction.new,
                      :LT => LTInstruction.new, :GT => LTInstruction.new, :STP => STPInstruction.new,
                      :NOP => NOPInstruction.new
                    }
  end
  
  def execute_all(code)
    @context = Context.new([code.size, code[0].size])
    while not @context.stopped do
      execute(code[@context.instruction_pointer[0]][@context.instruction_pointer[1]])
      @context.advance()
      sleep(0.05)
    end
  end
  
private  
  def execute(code_point)
    instruction = @instructions[code_point.instruction_symbol] or NOPInstruction.new
    arguments = code_point.arguments.map {|arg| if arg.is_ref? then @socket_manager[arg.value] else arg.value end }
    return_value = instruction.execute(@context, arguments[0], arguments[1])
    if code_point.reference then
      @socket_manager[code_point.reference] = return_value
    end
  end
end