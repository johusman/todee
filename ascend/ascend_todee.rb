require 'ascend/ascend'
require 'ascend/ascend_todee_mutations'
require 'todee/todee_parser'
require 'todee/todee_decompiler'

code = TodeeParser.new.parse_file(File.new(ARGV[0]))
candidate = CodeCandidate.new(code)

engine = AscendEngine.new(10) do |candidate|
 code = candidate.code
 return (code.size * 2 + code[0].size * 2) / (code.size * code[0].size)
end

engine.add_mutation(RemoveColumnMutation.new(), 0.1)
engine.add_mutation(RemoveRowMutation.new(), 0.1)
engine.add_mutation(DuplicateColumnMutation.new() => 0.1
engine.add_mutation(DuplicateRowMutation.new() => 0.1
engine.add_mutation(InstructionMutation.new(0, 6) => 0.5
engine.add_mutation(TargetMutation.new(0, 6) => 0.5
engine.add_mutation(ArgumentMutation.new(0, 6, 0.2) => 0.5
engine.add_mutation(SwitchRowsMutation.new() => 0.2
engine.add_mutation(SwitchColumnsMutation.new() => 0.2
engine.add_mutation(FlipBlockHorizontallyMutation.new() => 0.3
engine.add_mutation(FlipBlockVerticallyMutation.new() => 0.3

mutation = FlipBlockVerticallyMutation.new

rand(100).times() do
  mutations.each_pair do |mutation, probability|
    if rand() < probability then
      candidate = mutation.mutate(candidate)
      code = candidate.code
        if code.size > 0 then
          cols = code[0].size
          code.each do |row|
            if row.size != cols then
              raise "Assertion error after #{mutation.class}: after parsing file, failed to pad all rows to same length"
            end
            row.each do |code_point|
              if not code_point then
                raise "Assertion error after #{mutation.class}: nil:s detected in code block after parsing"
              end
            end
          end
        end
    end
  end
end

File.open('/tmp/mutated.2d', 'w') do |file|
  file.puts TodeeDecompiler.new.decompile_matrix(candidate.code)
end
