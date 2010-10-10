require 'todee/todee_sockets'
require 'todee/todee_engine'
require 'todee/todee_parser'
require 'todee/todee_environment_parser'


class VerboseStackSocket < StackSocket
  def read()
    value = super()
    puts @stack.map {|a| a = a % 256; (a > 9 and a < 128) ? a.chr : '?'}.join('')
    return value
  end

  def write(value)
    super(value)
    puts @stack.map {|a| a = a % 256; (a > 9 and a < 128) ? a.chr : '?'}.join('')
  end
end

class DebugListener < TodeeListenerBase
  def pre_execute(row, column, codepoint)
    puts "Executing\t#{row}\t#{column}\t#{codepoint.to_s}"
  end
  
  def post_execute(row, column, codepoint)
  end
  
  def read_socket(given_address, ref_level, actual_address, value)
    puts "Reading\t%#{actual_address} -> #{value}" if ref_level > 0
  end
  
  def write_socket(given_address, ref_level, actual_address, value)
    puts "Writing\t%#{actual_address} <- #{value}"
  end
end

def parse(code_file)
  map = {}
#  map[:environment] = TodeeEnvironmentParser.new.parse_file(File.new(environment_file))
  environment = TodeeEnvironment.new()
  environment.register_socket(VerboseStackSocket.new(),0)
  environment.register_socket(MemorySocket.new(), 1)
  environment.register_socket(StackSocket.new(), 2)
  map[:environment] = environment
  map[:code] = TodeeParser.new.parse_file(File.new(code_file))
  return map
end

def execute(environment, code, listener)
  engine = Engine.new(environment, code, listener)
  return engine.execute_all()
end


if ARGV.size < 1 then
  puts "Usage: program <source file>"
  exit(1)
end

fileargs = []
switches = []

ARGV.each() do |arg|
  match = arg.match(/^--?(.*)$/)
  if match then
    switches << match[1]
  else
    fileargs << arg
  end
end

num = 0

if switches.include?('gui') then
  require 'todee/todee_fx_view'
  
  listener = TodeeFXListener.new()
  map = parse(fileargs[0])
  begin
    num = listener.start(map[:environment], map[:code])
  ensure
    listener.stop()
  end
elsif switches.include?('debug') then
  map = parse(fileargs[0])
  num = execute(map[:environment], map[:code], DebugListener.new)
else
  map = parse(fileargs[0])
  num = execute(map[:environment], map[:code], TodeeListenerBase::NULL)
end

puts "Executed #{num} instructions"
