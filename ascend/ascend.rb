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

class Life
  attr_reader :candidate, :score, :ttl
  attr_writer :score

  def initialize(candidate, ttl, score)
    @candidate = candidate
    @score = score
    @ttl = ttl
  end

  def time_to_die?()
    @ttl -= 1
    return @ttl == 0
  end
end

class AscendEngine
  def initialize(options = {}, &fitness_function)
    @mutations = {}
    @offspring_per_candidate = options[:offspring_per_candidate] or 10
    @survivor_pool_size = options[:survivor_pool_size] or 10
    @candidate_ttl = options[:candidate_ttl] or 1
    @fitness_function = fitness_function
  end

  def add_mutation(mutation, probability)
    @mutations[mutation] = probability
  end

  def on_new_survivors(&on_new_survivors_block)
    if on_new_survivors_block.arity < 3 or on_new_survivors_block.arity > 4 then
      raise "The block to on_new_survivors takes 3 or 4 parameters: generation_number, candidate_array, score_array, [map of benchmarks]"
    end
    @on_new_survivors_block = on_new_survivors_block
  end

  def on_new_highscore(&on_new_highscore_block)
    if on_new_highscore_block.arity != 3 then
      raise "The block to on_new_highscore takes 3: generation_number, candidate, score"
    end
    @on_new_highscore_block = on_new_highscore_block
  end
  
  def evolve(original_candidate, generations)
    max_score = nil
    generation = 1
    best_lives = [Life.new(original_candidate, @candidate_ttl, @fitness_function.call(original_candidate))]
    generations.times() do
      offspring_candidates = []
      mutate_benchmark = Benchmark.measure do
        best_lives.each do |life|
          offspring_candidates.concat(reproduce_and_mutate(life.candidate))
        end
      end
      
      offspring_lives = nil
      fitness_benchmark = Benchmark.measure do
        offspring_lives = offspring_candidates.map { |child| Life.new(child, @candidate_ttl, @fitness_function.call(child)) }
        best_lives.each do |life|
          if not life.time_to_die? then
            life.score = @fitness_function.call(life.candidate)
            offspring_lives << life
          end
        end
      end
      best_lives = offspring_lives.sort() { |a, b| b.score <=> a.score }
      best_lives = best_lives[0..(@survivor_pool_size-1)]

      if defined? @on_new_survivors_block then
        if @on_new_survivors_block.arity == 4 then
          @on_new_survivors_block.call(generation, best_lives.map{|life| life.candidate}, best_lives.map{|life| life.score}, {:mutation => mutate_benchmark.real, :fitness => fitness_benchmark.real})
        else
          @on_new_survivors_block.call(generation, best_lives.map{|life| life.candidate}, best_lives.map{|life| life.score})
        end
      end

      best_life = best_lives[0]
      if not max_score or best_life.score > max_score
        max_score = best_life.score
        if defined? @on_new_highscore_block then
          @on_new_highscore_block.call(generation, best_life.candidate, best_life.score)
        end
      end
      generation += 1
    end
    puts
    return best_lives[0].candidate
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

