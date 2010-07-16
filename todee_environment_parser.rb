require 'todee_sockets'
require 'todee_environment'
require 'yaml'

class TodeeEnvironmentParseException < Exception; end

class TodeeEnvironmentParser
  def initialize()
    @socket_types = {
        'null'       => NullSocket,
        'memory'     => MemorySocket,
        'stack'      => StackSocket,
        'stdout'     => StdoutSocket,
        'stdin'      => StdinSocket,
        'stdio'      => StdioSocket,
        'networkout' => NetworkOutSocket,
        'networkin'  => NetworkInSocket,
        'queue'      => QueueSocket
      }
  end
  
  def parse_file(string)
    environment = TodeeEnvironment.new
    
    yaml = YAML::load(string)
    env_hash = yaml['TodeeEnvironment']
    if not env_hash then
      raise TodeeEnvironmentParseException, "Missing top level key 'TodeeEnvironment' in environment file"
    end
    env_hash.each_pair do |key, value|
      socket_type = @socket_types[value.downcase]
      
      if not socket_type then
        raise TodeeEnvironmentParseException, "Unknown socket type #{value}"
      end
      
      environment.register_socket(socket_type.new, key.to_i)
    end
    
    return environment
  end
end