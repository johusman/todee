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

parsed_code = nil
if ARGV.size > 0 then
  parsed_code = TodeeParser.new.parse_file(File.new(ARGV[0]))
else
  parsed_code = []
  5.times() do
    row = []
    5.times() do
      row << CodePoint::NOP
    end
    parsed_code << row
  end
end
candidate = CodeCandidate.new(parsed_code)

expected = "hello, world!"

max_score = -100000

engine = AscendEngine.new(:offspring_per_candidate => 5, :survivor_pool_size => 20, :candidate_ttl => 2) do |candidate|
  score = 0
  begin
    socket = MySocket.new()
    executed = run_candidate(candidate, socket)
    #if executed < 200 then
      score -= 1 * (socket.stack.size - expected.size).abs
      score -= (candidate.code.size * 0.5 + candidate.code[0].size * 0.5)
      for i in 0..(expected.size-1) do
        if socket.stack[i] and expected[i] == socket.stack[i] % 256
          score += 200
        else
          score += 2 if socket.stack.include?(expected[i])
          break
        end
      end
    #else
    #  raise "Too many operations"
    #end
  rescue
    score = -100000
  end
  score = (score + 80 * (rand() - 0.5)).to_i
  if score > max_score then
    max_score = score
  end
  score
end

engine.on_new_survivors() do |generation, candidates, scores|
  if generation % 50 == 0 then
    print "\n##{generation} "
  end
  print " [#{scores[0].to_i}]"
  $stdout.flush()
end

engine.on_new_highscore() do |generation, candidate, score|
  print "*"
  print 7.chr
  $stdout.flush()
  File.open("/tmp/mutated.#{score}.2d", 'w') do |file|
    file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
  end
end

engine.add_mutation(RemoveColumnMutation.new(), 0.1)
engine.add_mutation(RemoveRowMutation.new(), 0.1)
engine.add_mutation(DuplicateColumnMutation.new(), 0.1)
engine.add_mutation(DuplicateRowMutation.new(), 0.1)
engine.add_mutation(InstructionMutation.new(0, 2, 0.2), 0.8)
engine.add_mutation(TargetMutation.new(0, 2), 0.8)
engine.add_mutation(ArgumentMutation.new(0, 2, 0.3), 0.8)
engine.add_mutation(SwitchRowsMutation.new(), 0.2)
engine.add_mutation(SwitchColumnsMutation.new(), 0.2)
engine.add_mutation(FlipBlockHorizontallyMutation.new(), 0.3)
engine.add_mutation(FlipBlockVerticallyMutation.new(), 0.3)

candidate = engine.evolve(candidate, 10000)
                    
File.open('/tmp/mutated.2d', 'w') do |file|
  file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
end

socket = MySocket.new
run_candidate(candidate, socket)

puts "Result: " + socket.stack.map{|a| b = a % 256; (b > 9 and b < 128) ? b.chr : '?' }.join()
