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

def run_candidate(candidate, socket, socket2)
  environment = TodeeEnvironment.new()
  environment.register_socket(socket, 0)
  environment.register_socket(socket2, 1)
  for i in 2..21 do
    environment.register_socket(MemorySocket.new(), i)
  end
  environment.register_socket(StackSocket.new(), 22)
  environment.register_socket(QueueSocket.new(), 23)
  todee_engine = Engine.new(environment, candidate.code)
  return todee_engine.execute_some(400)
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

#expected = [0, 1, 1, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765] #"hello, world!"

engine = AscendEngine.new(:offspring_per_candidate => 5, :survivor_pool_size => 20, :candidate_ttl => 2) do |candidate|
  score = (candidate.code.size + candidate.code[0].size) > 100 ? -(candidate.code.size + candidate.code[0].size - 100) * 0.5 : 0
  begin
    socket = MySocket.new()
    socket2 = MySocket.new()
    
    matching = 0.0
    4.times() do
      array = []
      10.times() do
        value = rand(1000)
        array << value
        socket.write(value)
      end
      sorted_array = array.sort

      executed = run_candidate(candidate, socket, socket2)
    #if executed < 200 then
      for i in 0..9 do
        a = socket2.stack.index(sorted_array[i])
        if a then
          d = (a-i).abs
          matching += 1.0/(d+1.0)
        end
      end
    end

#    matching = 0
#      fiba, fibb = 0, 1
#      for i in 0..100 do
#        if socket.stack[i] and fiba == socket.stack[i]
#          matching += 1
#        elsif socket.stack[i] and (fiba - socket.stack[i]).abs < 10 then
#          matching += 0.2 / (fiba - socket.stack[i]).abs
#        else
#          break
#        end
#        fiba, fibb = fibb, fiba+fibb
#      end
    score += 100 * (1.3**(matching + score))
    #else
    #  raise "Too many operations"
    #end
  rescue
    score = -100
  end
  #(score + 80 * (rand() - 0.5)).to_i
  score.to_i
end

engine.on_new_survivors() do |generation, candidates, scores|
  if generation % 50 == 0 then
    $stderr.print "\n##{generation} "
    $stderr.flush()
  end
  top_history = candidates[0].history
  smallest_common_ancestry = nil
  candidates.each() do |candidate|
    history = candidate.history
    pos = 0
    pos +=1 while history[pos] == top_history[pos] and pos < top_history.size
    smallest_common_ancestry = pos if not smallest_common_ancestry or pos < smallest_common_ancestry
    #puts "[#{history.join(', ')}]"
  end
  puts "#{scores[0].to_i} #{(scores.inject(0){|sum, val| sum+val}/scores.size).to_i} #{scores[-1].to_i} #{top_history.size - smallest_common_ancestry}"
  $stdout.flush()
end

engine.on_new_highscore() do |generation, candidate, score|
  $stderr.print "*"
  $stderr.puts 7.chr
  $stderr.flush()
  File.open("/tmp/mutated.#{score}.2d", 'w') do |file|
    file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
  end
end

engine.add_mutation(RemoveColumnMutation.new(), 0.1)
engine.add_mutation(RemoveRowMutation.new(), 0.1)
engine.add_mutation(DuplicateColumnMutation.new(), 0.1)
engine.add_mutation(DuplicateRowMutation.new(), 0.1)
engine.add_mutation(InstructionMutation.new(0, 5, 0.2), 0.8)
engine.add_mutation(TargetMutation.new(0, 5), 0.8)
engine.add_mutation(ArgumentMutation.new(0, 5, 0.3), 0.8)
engine.add_mutation(SwitchRowsMutation.new(), 0.2)
engine.add_mutation(SwitchColumnsMutation.new(), 0.2)
engine.add_mutation(FlipBlockHorizontallyMutation.new(), 0.3)
engine.add_mutation(FlipBlockVerticallyMutation.new(), 0.3)

candidate = engine.evolve(candidate, 50000)
                    
File.open('/tmp/mutated.2d', 'w') do |file|
  file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
end

socket = MySocket.new
run_candidate(candidate, socket)

puts "Result: " + socket.stack.map{|a| b = a % 256; (b > 9 and b < 128) ? b.chr : '?' }.join()
