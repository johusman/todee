require 'benchmark'

class Mutation
  def mutate(candidate)
    if not candidate.respond_to?(:copy) then
      raise "Candidate classes must respond to method 'copy'. Given candidate '#{candidate.to_s}' of class '#{candidate.class.to_s}' did not"
    end
    return candidate.copy()
  end
end

class Candidate
  def copy()
    return self.clone()
  end
end

class AscendEngine
  def initialize(offspring_per_candidate, &fitness_function)
    @mutations = {}
    @offspring_per_candidate = offspring_per_candidate
    @fitness_function = fitness_function
  end

  def add_mutation(mutation, probability)
    @mutations[mutation] = probability
  end
  
  def evolve(original_candidate, generations)
    generation = 1
    candidate_with_score = { :candidate => original_candidate, :score => @fitness_function.call(original_candidate) }
    generations.times() do
      print "##{generation}: "
      offspring = nil
      mutate_benchmark = Benchmark.measure do
        offspring = reproduce_and_mutate(candidate_with_score[:candidate])
      end
      offspring_with_score = nil
      fitness_benchmark = Benchmark.measure do
        offspring_with_score = offspring.map { |child| { :candidate => child, :score => @fitness_function.call(child) } }
      end
      candidate_with_score[:score] = @fitness_function.call(candidate_with_score[:candidate])
      candidate_with_score = offspring_with_score.inject(candidate_with_score) { |best, tuple| tuple[:score] >= best[:score] ? tuple : best }
      selected_candidate = candidate_with_score[:candidate]
      puts "Selecting #{selected_candidate} [#{selected_candidate.code.size*selected_candidate.code[0].size}] with score #{candidate_with_score[:score]};\t#{mutate_benchmark.real}"
      generation += 1
    end
    
    return candidate_with_score[:candidate]
  end
  
  def reproduce_and_mutate(candidate)
    offspring = []
    @offspring_per_candidate.times() do
      offspring << candidate.copy()
    end
    
    mutated_offspring = offspring.map do |child|
      (rand(3)+1).times() do
        @mutations.each_pair do |mutation, probability|
          if rand() < probability then
            child = mutation.mutate(child)
          end
        end
      end
      child
    end
    
    return mutated_offspring
  end
end

