require 'ascend/ascend'
require 'ascend/ascend_todee_mutations'
require 'todee/todee_parser'
require 'todee/todee_decompiler'
require 'todee/todee_sockets'
require 'todee/todee_environment'
require 'todee/todee_engine'

class MySocket < StackSocket
  attr_reader :stack
end

def run_candidate(candidate, socket)
  environment = TodeeEnvironment.new()
  environment.register_socket(socket, 0)
  environment.register_socket(MemorySocket.new(), 1)
  environment.register_socket(StackSocket.new(), 2)
  todee_engine = Engine.new(environment, candidate.code)
  return todee_engine.execute_some(200)
end

#parsed_code = TodeeParser.new.parse_file(File.new(ARGV[0]))
parsed_code = []
5.times() do
  row = []
  5.times() do
    row << CodePoint::NOP
  end
  parsed_code << row
end
candidate = CodeCandidate.new(parsed_code)

expected = "hello, world!"

engine = AscendEngine.new(10) do |candidate|
  score = 0
  begin
    socket = MySocket.new()
    executed = run_candidate(candidate, socket)
    if executed < 200 then
      score -= 10 * ((socket.stack.size - expected.size).abs/10)
      score -= 50 * ((candidate.code.size * candidate.code[0].size)/100)
      for i in 0..(expected.size-1) do
        score += 200 if socket.stack[i] and expected[i] == socket.stack[i] % 256
        score += 50 if socket.stack.include?(expected[i])
      end
    else
      raise "Too many operations"
    end
  rescue
    score = -100000
  end
  score + 110 * (rand() - 0.5)
end

engine.add_mutation(RemoveColumnMutation.new(), 0.1)
engine.add_mutation(RemoveRowMutation.new(), 0.1)
engine.add_mutation(DuplicateColumnMutation.new(), 0.1)
engine.add_mutation(DuplicateRowMutation.new(), 0.1)
engine.add_mutation(InstructionMutation.new(0, 2), 0.8)
engine.add_mutation(TargetMutation.new(0, 2), 0.8)
engine.add_mutation(ArgumentMutation.new(0, 2, 0.2), 0.8)
engine.add_mutation(SwitchRowsMutation.new(), 0.2)
engine.add_mutation(SwitchColumnsMutation.new(), 0.2)
engine.add_mutation(FlipBlockHorizontallyMutation.new(), 0.3)
engine.add_mutation(FlipBlockVerticallyMutation.new(), 0.3)

candidate = engine.evolve(candidate, 5000)
                    
File.open('/tmp/mutated.2d', 'w') do |file|
  file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
end

socket = MySocket.new
run_candidate(candidate, socket)

puts "Result: " + socket.stack.map{|a| b = a % 256; (b > 9 and b < 128) ? b.chr : '?' }.join()
