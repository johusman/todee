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
    @offspring_per_candidate
    @fitness_function = fitness_function
  end

  def add_mutation(mutation, probability)
    @mutations[mutation] = probability
  end
  
  def evolve(original_candidate, generations)
    candidate_with_score = { :candidate => original_candidate, :score => @fitness_function.call(child) }
    generations.times() do
      offspring = reproduce_and_mutate(candidate_with_score[:candidate])
      offspring_with_score = offspring.map { |child| { :candidate => child, :score => @fitness_function.call(child) } }
      candidate_with_score = offspring_with_score.inject(candidate_with_score) { |best, tuple| tuple[:score] > best[:score] ? tuple : best }
    end
    
    return candidate_with_score[:candidate]
  end
  
  def reproduce_and_mutate(candidate)
    offspring = []
    @offspring_per_candidate.times() do
      offspring << candidate.copy()
    end
    
    mutated_offspring = offspring.map do |child|
      rand(5).times() do
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

