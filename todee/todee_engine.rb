require 'todee/todee_instructions'
require 'todee/todee_code_utils'
require 'todee/todee_listener_base'

class ExecutionContext
  attr_reader :instruction_pointer, :stopped, :bounds
  
  def initialize(bounds, environment)
    @state_stack = []
    @instruction_pointer = [0, 0] # row, column
    @direction = [1, 0] # row, column
    @stopped = false
    @bounds = bounds
    
    # 0 = down, 1 = right, 2 = up, 3 = left
    @directions = [[1, 0], [0, 1], [-1, 0], [0, -1]] # row, column
    
    @environment = environment
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
    #puts "at: #{@instruction_pointer[0]}, #{@instruction_pointer[1]}"
  end
  
  def reset()
    @instruction_pointer = [0, 0]
    @direction = [1, 0]
  end
  
  def jump(distance)
    return if distance == 0
    distance -= 1 # because advance() will be called after this
    advance_one_dimension_by(0, distance * @direction[0])
    advance_one_dimension_by(1, distance * @direction[1])
  end
  
  def call_jump(distance)
    push_state()
    jump(distance)
  end
  
  def return_jump()
    pop_state()
  end
  
  def drop_call()
    drop_state()
  end

private

  def advance_one_dimension(dim)
    advance_one_dimension_by(dim, @direction[dim])
  end
  
  def advance_one_dimension_by(dim, distance)
    @instruction_pointer[dim] += distance
    @instruction_pointer[dim] %= @bounds[dim]
  end
  
  def push_state()
    #$stderr.puts("Pushing state stack: #{{ :pointer => @instruction_pointer, :direction => @direction }}")
    @state_stack.push({ :pointer => Array.new(@instruction_pointer), :direction => Array.new(@direction) })
    @environment.push_call()
  end
  
  def pop_state()
    state = @state_stack.pop()
    #$stderr.puts("Popping state stack: #{state}")
    if state then
      @instruction_pointer = state[:pointer]
      @direction = state[:direction]
    end
    @environment.pop_call()
  end
  
  def drop_state()
    @state_stack.pop()
    #$stderr.puts("Dropping state stack: #{state}")
    @environment.drop_call()
  end  
end

class Engine
  include CodeUtils
  
  def initialize(environment, listener = TodeeListenerBase::NULL)
    @environment = environment
    @listener = listener
    @NOP = NOPInstruction.new
  end  
  
  def execute_all(code)
    @context = ExecutionContext.new([code.size, code[0].size], @environment)
    instructions_executed = 0
    while not @context.stopped do
      row = @context.instruction_pointer[0]
      col = @context.instruction_pointer[1]
      code_point = code[row][col]
      @listener.pre_execute(row, col, code_point)
      execute(code_point)
      @listener.post_execute(row, col, code_point)
      @context.advance()
      #sleep(0.01)
      instructions_executed += 1
    end
    
    return instructions_executed
  end
  
private  
  def execute(code_point)
    instruction = code_point.instruction_symbol ? get_instruction(code_point.instruction_symbol) : @NOP
    raise "#{code_point.instruction_symbol} is not a valid instruction!" if not instruction
    
    arguments = code_point.arguments.map {|arg| @environment.deref_read(arg.value, arg.ref_level, @listener)}
    return_value = instruction.execute(@context, arguments[0], arguments[1])
    target = code_point.target
    if target then
      @environment.deref_write(target.value, target.ref_level, return_value, @listener)
    end
  end
end
