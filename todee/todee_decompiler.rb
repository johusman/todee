class TodeeDecompiler
  def decompile_matrix(matrix)
    matrix.map {|row| row.map {|codepoint| decompile_codepoint(codepoint)}.join("\t") + "\n"}.join()
  end
  
  def decompile_codepoint(codepoint)
    instruction = codepoint.instruction_symbol
    case instruction
    when :NOP then "."
    when :TUR then
      if codepoint.arguments[0].ref_level == 0 then 
        case codepoint.arguments[0].value
        when 0 then "|v|"  
        when 1 then "|>|"
        when 2 then "|^|"
        when 3 then "|<|"
        else
          standard_decompile(codepoint)
        end
      else
        standard_decompile(codepoint)
      end
    else
      standard_decompile(codepoint)
    end
  end
  
  def standard_decompile(codepoint)
    instruction = codepoint.instruction_symbol
    arg_array = codepoint.arguments.map { |value| if value then value.to_s else '_' end }
    arg_array.unshift(codepoint.target.to_s) if codepoint.target
    "#{instruction}#{arg_array.empty? ? '' : ' '}#{arg_array.join(", ")}"
  end
end