require 'todee_codepoint'
require 'todee_code_utils'

class TodeeParseException < Exception; end

class TodeeParser
  include CodeUtils
  
  def initialize()
    @aliases = {
        "." => CodePoint.new(:NOP, nil, []),
        "|V|" => CodePoint.new(:TUR, nil, [Argument.new(0, 0)]),
        "|>|" => CodePoint.new(:TUR, nil, [Argument.new(1, 0)]),
        "|^|" => CodePoint.new(:TUR, nil, [Argument.new(2, 0)]),
        "|<|" => CodePoint.new(:TUR, nil, [Argument.new(3, 0)])
      }
  end
  
  def parse_file(file)
    if not file.respond_to?("each_line") then
      raise ArgumentError, "Unknown argument type #{file.type}. Must support each_line()"
    end
    
    code = []
    
    file.each_line() do |line|
      code_points = parse_code_points(line)
      if code_points.size > 0 then
        code << code_points
      end
    end
    
    max_cols = code.reduce(0) {|max,row| if row.size > max then row.size else max end }
    code.each() do |row|
      fill_size = max_cols - row.size
      if fill_size > 0 then
        filler = [CodePoint::NOP] * fill_size
        row.push(*filler)
      end
    end
    
    return code
  end

  def parse_code_points(string)
    code_points = []
    until not string or string.strip.empty?
      code_point, string = consume_code_point(string)
      if code_point then
        code_points << code_point
      end
    end
    
    return code_points
  end
  
  def consume_code_point(string)
    work_string = string.gsub(/(?!')[*](?!')/, ' ').strip
    if work_string.match(/^\s*#/) then
      return [nil, nil] # line is a comment
    end
    
    op, work_string = consume_op(work_string)
    if not op then
      raise_error "Expected instruction name at the beginning of '#{work_string}'", string
    end
    
    op = op.upcase.strip
    
    return [@aliases[op], work_string] if @aliases[op]
    
    op = op.to_sym
    
    instruction = get_instruction(op)
    
    if not instruction then
      raise_error "Instruction '#{op}' could not be found", string
    end
    
    params, work_string = consume_parameters(work_string)
    
    target = nil
    if instruction.takes_target then
      target_param = params.shift
      if not target_param then
        raise_error "Instruction '#{op}' takes a target argument, but there were no arguments given", string
      end
      target = parse_param(target_param) 
      if not target then
        raise_error "Argument #{target_param} is not a valid argument (should be [%[%]]<number> or '<character>')", string
      end
      if target and target.ref_level == 0 then
        raise_error "First argument to instruction '#{op}' is a target and must therefore be a reference, but was: '#{target_param}'", string
      end
    end
    
    if params.size != instruction.num_args then
      raise_error "Instruction '#{op}' takes #{instruction.num_args + (instruction.takes_target ? 1 : 0)} arguments, but was given #{params.size + (target ? 1 : 0)}", string
    end
    
    args = params.map do |param|
      parsed = parse_param(param)
      if not parsed then
        raise_error "Argument #{param} is not a valid argument (should be [%[%]]<number> or '<character>')", string
      else
        parsed
      end
    end
    
    return [CodePoint.new(op, target, args), work_string]
  end
private

  def raise_error(message, string)
    error_message = "#{message} (while parsing '#{string.strip}')"
    raise TodeeParseException, error_message
  end

  def consume_op(string)
    match = string.match(/^([.]|([\w|^V<>]+))\s*(.*)/)
    if match then
      return [match[1], match[3]]
    else
      return [nil, string]
    end
  end
  
  def consume_parameter(string)
    match = string.match(/^\s*(([%\-0-9]+)|('[^']?'))(.*)/)
    if match then
      return [match[1], match[4]]
    else
      return [nil, string]
    end
  end
  
  def consume_parameters(string)
    params = []
    work_string = string
    while true
      param, work_string = consume_parameter(work_string)
      if param
	params << param
	delim_match = work_string.match(/^\s*,\s*(.*)/)
	if delim_match
	  work_string = delim_match[1]
	else
	  return [params, work_string]
	end
      else
	return [params, work_string]
      end 
    end
  end
  
  def parse_param(param)
    param = param.strip
    
    if not param.match(/^((%{1,2}|-)?[0-9]+)|('[^']?')$/) then
      return nil
    end
    
    ref_level = 0
    metaref_match = param.match(/^%%(.*)/)
    if metaref_match then
      ref_level = 2
      param = metaref_match[1]
    else
      ref_match = param.match(/^%(.*)/)
      if ref_match then
        ref_level = 1
        param = ref_match[1]
      end
    end
    
    quote_match = param.match(/^'([^']?)'$/)
    if quote_match then
      if quote_match[1] and not quote_match[1].empty? then
        param = quote_match[1][0].to_s
      else
        param = "'"[0].to_s
      end
    end
    
    return nil if not param.match(/^-?[0-9]+$/)
    
    return Argument.new(param.to_i, ref_level)
  end
end