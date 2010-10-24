require 'todee/todee_instructions'
require 'todee/todee_code_utils'
require 'todee/todee_listener_base'

class Vector2D
  attr_reader :row, :col
  attr_writer :row, :col

  def initialize(row, col)
    @row = row
    @col = col
  end
end

class ExecutionContext
  attr_reader :instruction_pointer, :stopped, :bounds
  
  def initialize(rows, cols, environment)
    @state_stack = []
    reset()
    @stopped = false
    @bounds = Vector2D.new(rows, cols)
    
    # 0 = down, 1 = right, 2 = up, 3 = left
    @directions = [Vector2D.new(1, 0), Vector2D.new(0, 1), Vector2D.new(-1, 0), Vector2D.new(0, -1)] # row, column
    
    @environment = environment
  end
  
  def turn_to(direction)
    new_dir = @directions[direction]
    if new_dir
      @direction = new_dir
    end
  end
  
  def turn_left()
    @direction = Vector2D.new(-@direction.col, @direction.row)
  end
  
  def turn_right()
    @direction = Vector2D.new(@direction.col, -@direction.row)
  end
  
  def stop()
    @stopped = true
  end
  
  def advance()
    advance_by(@direction.row, @direction.col)
  end
  
  def reset()
    @instruction_pointer = Vector2D.new(0, 0)
    @direction = Vector2D.new(1, 0)
  end
  
  def jump(distance)
    return if distance == 0
    distance -= 1 # because advance() will be called after this
    advance_by(distance * @direction.row, distance * @direction.col)
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

  def advance_by(rows, cols)
    @instruction_pointer.row += rows
    @instruction_pointer.col += cols
    @instruction_pointer.row %= @bounds.row if @instruction_pointer.row >= @bounds.row or @instruction_pointer.row < 0
    @instruction_pointer.col %= @bounds.col if @instruction_pointer.col >= @bounds.col or @instruction_pointer.col < 0
  end
  
  def push_state()
    @state_stack.push({ :pointer => @instruction_pointer.clone, :direction => @direction.clone })
    @environment.push_call()
  end
  
  def pop_state()
    state = @state_stack.pop()
    if state then
      @instruction_pointer = state[:pointer]
      @direction = state[:direction]
    end
    @environment.pop_call()
  end
  
  def drop_state()
    @state_stack.pop()
    @environment.drop_call()
  end  
end

class Engine
  include CodeUtils
  
  def initialize(environment, code, listener = TodeeListenerBase::NULL)
    @environment = environment
    @code = code
    @listener = listener
    @NOP = NOPInstruction.new
    @context = nil
  end  
  
  def execute_all()
    @context = ExecutionContext.new(@code.size, @code[0].size, @environment)
    instructions_executed = 0
    while not @context.stopped do
      execute_next()
      instructions_executed += 1
    end
    
    return instructions_executed
  end
  
  def execute_some(count)
    @context = ExecutionContext.new(@code.size, @code[0].size, @environment) if not @context
    instructions_executed = 0
    count.times() do
      if @context.stopped then
        return instructions_executed
      end
      execute_next()
      instructions_executed += 1
    end
    
    return instructions_executed
  end
  
private  

  def execute_next()
    row = @context.instruction_pointer.row
    col = @context.instruction_pointer.col
    code_point = @code[row][col]
    @listener.pre_execute(row, col, code_point)
    execute(code_point)
    @listener.post_execute(row, col, code_point)
    @context.advance()
  end
  
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
