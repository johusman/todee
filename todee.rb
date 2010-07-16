require 'todee_sockets'
require 'todee_engine'
require 'todee_parser'
require 'todee_environment_parser'

if ARGV.size < 2 then
  puts "Usage: todee <environment file> <source file>"
  exit(1)
end

environment = TodeeEnvironmentParser.new.parse_file(File.new(ARGV[0]))
code = TodeeParser.new.parse_file(File.new(ARGV[1]))

engine = Engine.new(environment)
engine.execute_all(code)
