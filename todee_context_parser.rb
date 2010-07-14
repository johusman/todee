require 'todee_sockets'
require 'yaml'

class TodeeContextParseException < Exception; end

class TodeeContextParser
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
    manager = SocketManager.new
    
    yaml = YAML::load(string)
    context_hash = yaml['Context']
    if not context_hash then
      raise TodeeContextParseException, "Missing top level key 'Context' in context file"
    end
    context_hash.each_pair do |key, value|
      socket_type = @socket_types[value.downcase]
      
      if not socket_type then
        raise TodeeContextParseException, "Unknown socket type #{value}"
      end
      
      manager.register_socket(socket_type.new, key.to_i)
    end
    
    return manager
  end
end