require 'todee_sockets'
require 'todee_environment'
require 'yaml'

class TodeeEnvironmentParseException < Exception; end

class TodeeEnvironmentParser
  def initialize()
    @socket_types = {
        'null'       => NullSocket,
        'memory'     => MemorySocket,
        'scope'      => ScopeMemorySocket,
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
      
      if key.to_s.match(/^\s*[0-9]+\s*$/) then
        environment.register_socket(socket_type.new, key.to_i)
      elsif key.to_s.match(/^\s*[0-9]+-[0-9]+\s*$/) then
        match = key.match(/^\s*([0-9]+)-([0-9]+)\s*$/)
        start = match[1].to_i
        stop  = match[2].to_i
        if start > stop then
          raise TodeeEnvironmentParseException, "Invalid range: #{key}"
        else
          (start..stop).each do |index|
            environment.register_socket(socket_type.new, index)
          end
        end
      else
        raise TodeeEnvironmentParseException, "Unrecognized specification: #{key}"
      end
    end
    
    return environment
  end
end