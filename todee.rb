require 'todee/todee_sockets'
require 'todee/todee_engine'
require 'todee/todee_parser'
require 'todee/todee_environment_parser'

if ARGV.size < 2 then
  puts "Usage: todee <environment file> <source file>"
  exit(1)
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

environment = TodeeEnvironmentParser.new.parse_file(File.new(ARGV[0]))
code = TodeeParser.new.parse_file(File.new(ARGV[1]))

#engine = Engine.new(environment, DebugListener.new)
engine = Engine.new(environment)
num = engine.execute_all(code)

puts "Executed #{num} instructions"
