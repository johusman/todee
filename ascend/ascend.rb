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
  attr_writer :history
  attr_reader :history

  def initialize()
    @counter = AscendCounter.new()
    @history = [@counter.next]
  end

  def copy()
    my_clone = self.clone()
    my_clone.history = @history.clone
    my_clone.history << @counter.next
    return my_clone
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

class AscendCounter
  attr_reader :id
  attr_writer :id

  def initialize()
    @id = 0
  end

  def next()
    @id += 1
    @id
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

    survivor_pool = [Life.new(original_candidate, @candidate_ttl, @fitness_function.call(original_candidate))]

    generations.times() do
      offspring_candidates = []
      mutate_benchmark = Benchmark.measure do
        survivor_pool.each do |life|
          offspring_candidates.concat(reproduce_and_mutate(life.candidate))
        end
      end
      
      offspring_lives = nil
      fitness_benchmark = Benchmark.measure do
        offspring_lives = offspring_candidates.map { |child| Life.new(child, @candidate_ttl, @fitness_function.call(child)) }
        survivor_pool.each do |life|
          if not life.time_to_die? then
            life.score = @fitness_function.call(life.candidate)
            offspring_lives << life
          end
        end
      end

      survivor_pool = select_survivors(offspring_lives) 
      if defined? @on_new_survivors_block then
        if @on_new_survivors_block.arity == 4 then
          @on_new_survivors_block.call(generation, survivor_pool.map{|life| life.candidate}, survivor_pool.map{|life| life.score}, {:mutation => mutate_benchmark.real, :fitness => fitness_benchmark.real})
        else
          @on_new_survivors_block.call(generation, survivor_pool.map{|life| life.candidate}, survivor_pool.map{|life| life.score})
        end
      end

      best_life = survivor_pool[0]
      if not max_score or best_life.score > max_score
        max_score = best_life.score
        if defined? @on_new_highscore_block then
          @on_new_highscore_block.call(generation, best_life.candidate, best_life.score)
        end
      end
      generation += 1
    end
    return survivor_pool[0].candidate
  end
  
  def reproduce_and_mutate(candidate)
    offspring = []
    @offspring_per_candidate.times() do
      offspring << candidate.copy()
    end
    
    mutated_offspring = offspring.map do |child|
      (rand(2)+1).times() do
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

  def select_survivors(offspring_lives)
    survivors = []
    sorted_lives = offspring_lives.sort() { |a, b| b.score <=> a.score }

    survivors << sorted_lives.delete_at(0)
 
    (@survivor_pool_size-1).times() do
      if sorted_lives.size > 1 then
        score_min = sorted_lives.inject(sorted_lives[0].score) { |min, life| min > life.score ? life.score : min }
        bias = -score_min
        score_sum = sorted_lives.inject(0) { |sum, life| sum + life.score + bias }
        cutoff = (score_sum > 0 ? rand(score_sum) : 0)

        index = 0
        sub_sum = 0
        while sub_sum < cutoff do
          sub_sum += sorted_lives[index].score + bias
          index += 1
        end
    
        survivors << sorted_lives.delete_at(index-1)
      elsif sorted_lives.size == 1 then
        survivors << sorted_lives[0]
        sorted_lives = []
      end
    end
    return survivors.sort() { |a, b| b.score <=> a.score }
  end
end

