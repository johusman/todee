require 'ascend/ascend'
require 'todee/todee_codepoint'
require 'todee/todee_parser'
require 'todee/todee_decompiler'
require 'todee/todee_code_utils'

class CodeCandidate < Candidate
  attr_reader :code
  
  def initialize(code)
    @code = code
  end
  
  def copy()
    return CodeCandidate.new(@code.map {|row| row.map {|code_point| code_point ? code_point.copy() : nil}})
  end
end

class AbstractCodePointMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    
    code = candidate.code
    
    code_points = []
    code.each do |row|
      row.each do |code_point|
        code_points << code_point
      end
    end
    
    code_point = code_points[rand(code_points.size)]
    
    mutate_code_point!(code_point)
    
    return candidate
  end
  
  def mutate_code_point!(code_point)
    raise "class '#{self.class.to_s}' needs to override the method 'mutate_code_points!'"
  end
end

class ArgumentMutation < AbstractCodePointMutation
  def initialize(lowest_socket_address, highest_socket_address, probability_of_changing_reflevel)
    @lowest_socket_address = lowest_socket_address
    @highest_socket_address = highest_socket_address
    @probability_of_changing_reflevel = probability_of_changing_reflevel
  end
  
  def mutate_code_point!(code_point)
    if code_point.arguments.size > 0 then
      index = rand(code_point.arguments.size)
      code_point.arguments[index] = mutate_argument(code_point.arguments[index])
    end
  end
  
  def mutate_argument(argument)
    value, ref_level = argument.value, argument.ref_level

    change_reflevel = (rand() < @probability_of_changing_reflevel)
    
    if change_reflevel then
      increse = (rand(2) == 0)
      if increse or ref_level == 0 then
        ref_level += 1
      else
        ref_level -= 1
      end
    end
    
    if ref_level > 0 and (not change_reflevel or value > @highest_socket_address or value < @lowest_socket_address) then
      value = rand(@highest_socket_address - @lowest_socket_address + 1) + @lowest_socket_address
    elsif ref_level == 0 and not change_reflevel then
      if rand(2) == 0 then
        value += 2**rand(10)
      else
        value -= 2**rand(10)
      end
    end
    
    return Argument.new(value, ref_level)
  end
end

class TargetMutation < ArgumentMutation
  def initialize(lowest_socket_address, highest_socket_address)
    super(lowest_socket_address, highest_socket_address, 0)
  end
  
  def mutate_code_point!(code_point)
    if code_point.target then
      code_point.target = mutate_argument(code_point.target)
    end
  end
end

class InstructionMutation < AbstractCodePointMutation
  include CodeUtils
  
  INSTRUCTIONS = [:TUR, :TNR, :TNL, :STP, :NOP, :JMP, :CAL, :RET,
                  :DRP, :ADD, :SUB, :MUL, :DIV, :REM, :NEG, :MOV,
                  :AND, :OR, :XOR, :NOT, :EQ, :NEQ, :LT, :GT]
  
  def initialize(lowest_socket_address, highest_socket_address)
    @lowest_socket_address = lowest_socket_address
    @highest_socket_address = highest_socket_address
  end
  
  def mutate_code_point!(code_point)
    new_instruction_symbol = INSTRUCTIONS[rand(INSTRUCTIONS.size)]
    new_instruction = get_instruction(new_instruction_symbol)
    if new_instruction.takes_target then
      old_target = code_point.target
      if old_target then
        code_point.target = old_target
      else
        code_point.target = Argument.new(rand(@highest_socket_address - @lowest_socket_address + 1) + @lowest_socket_address, 1)
      end
    else
      code_point.target = nil
    end
    
    if new_instruction.num_args > code_point.arguments.size then
      (new_instruction.num_args - code_point.arguments.size).times() do
        code_point.arguments << Argument.new(rand(64), 0)
      end
    elsif new_instruction.num_args == 0 then
      code_point.arguments = []
    elsif new_instruction.num_args < code_point.arguments.size then
      code_point.arguments = code_point.arguments[0..(new_instruction.num_args-1)]
    end
    
    code_point.instruction_symbol = new_instruction_symbol
  end
end

class DuplicateRowMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    
    code = candidate.code
    
    row_index = rand(code.size)
    new_row = code[row_index].map {|code_point| code_point.copy()}
    code.insert(row_index, new_row)
    
    return candidate
  end
end

class RemoveRowMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    
    candidate.code.delete_at(rand(candidate.code.size))
    
    return candidate
  end
end

class DuplicateColumnMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    
    code = candidate.code
    
    column_index = rand(code[0].size)
    code.each do |row|
      row.insert(column_index, row[column_index] ? row[column_index].copy() : nil)
    end
    
    return candidate
  end
end

class RemoveColumnMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    
    code = candidate.code
    
    column_index = rand(code[0].size)
    code.each do |row|
      row.delete_at(column_index)
    end
    
    return candidate
  end
end

class SwitchRowsMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    index1 = rand(candidate.code.size)
    index2 = rand(candidate.code.size)
    candidate.code[index1], candidate.code[index2] = candidate.code[index2], candidate.code[index1]

    return candidate;
  end
end

class SwitchColumnsMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    index1 = rand(candidate.code[0].size)
    index2 = rand(candidate.code[0].size)
    candidate.code.each do |row|
      row[index1], row[index2] = row[index2], row[index1]
    end

    return candidate;
  end
end

class FlipBlockMutation < Mutation
  def mutate(candidate)
    candidate = super(candidate)
    width, height = candidate.code[0].size, candidate.code.size

    row1, col1 = rand(height), rand(width)
    row2, col2 = rand(height), rand(width)

    if row1 == row2 or col1 == col2 then
      return candidate
    end

    row1, row2 = row2, row1 if row1 > row2
    col1, col2 = col2, col1 if col1 > col2

    flip!(code, row1, col1, row2, col2)

    return candidate;
  end

  def flip!(code, row1, col1, row2, col2)
  end
end

class FlipBlockHorizontallyMutation < FlipBlockMutation
  def flip!(code, row1, col1, row2, col2)
    code[row1..row2].each do |row|
      row[col1..col2] = row[col1..col2].reverse
    end
  end
end

class FlipBlockVerticallyMutation < FlipBlockMutation
end

mutation = RemoveColumnMutation.new()

code = TodeeParser.new.parse_file(File.new(ARGV[0]))
File.open('/tmp/original.2d', 'w') do |file|
  file.puts TodeeDecompiler.new.decompile_matrix(code)
end

candidate = CodeCandidate.new(code)

mutations = [RemoveColumnMutation.new(), RemoveRowMutation.new(), DuplicateColumnMutation.new(), DuplicateRowMutation.new(), InstructionMutation.new(0, 6), TargetMutation.new(0, 6), ArgumentMutation.new(0, 6, 0.2)]

rand(5).times() do
  mutations.each do |mutation|
    if rand(10) == 0 then
      candidate = mutation.mutate(candidate)
    end
  end
end

File.open('/tmp/mutated.2d', 'w') do |file|
  file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
end