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
