require 'todee_sockets'
require 'todee_engine'
require 'todee_parser'
require 'todee_context_parser'

if ARGV.size < 2 then
  puts "Usage: todee <context file> <source file>"
  exit(1)
end

socket_manager = TodeeContextParser.new.parse_file(File.new(ARGV[0]))
code = TodeeParser.new.parse_file(File.new(ARGV[1]))

engine = Engine.new(socket_manager)
engine.execute_all(code)
