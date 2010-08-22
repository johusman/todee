require 'todee_sockets'

class TodeeEnvironment
  def initialize()
    @sockets = []
  end
  
  def register_socket(socket, address)
    @sockets[address.to_i] = socket
  end
  
  def socket(address)
    @sockets[address.to_i] or NullSocket.new
  end
  
  def sockets()
    return Array.new(@sockets)
  end
  
  def read(address)
    value = socket(address).read()
    #$stderr.puts "read #{value} from %#{address}"
    return value
  end
  
  def write(address, value)
    socket(address).write(value)
    #$stderr.puts "wrote #{value} to %#{address}"
  end
  
  def [](address)
    read(address)
  end
  
  def []=(address, value)
    write(address, value)
  end
  
  def deref_read(address, ref_level)
    until ref_level == 0 do
      address = read(address.to_i)
      ref_level -= 1
    end
    
    return address.to_i
  end
  
  def deref_write(address, ref_level, value)
    if address and ref_level > 0 then
      until ref_level == 1 do
        address = read(address)
        return if not address
        ref_level -= 1
      end
      
      write(address, value)
    end
  end
  
  def push_call()
    delegate_to_applicable(:push_call)
  end
  
  def pop_call()
    delegate_to_applicable(:pop_call)
  end
  
  def drop_call()
    delegate_to_applicable(:drop_call)
  end
  
private
  def delegate_to_applicable(method)
    @sockets.each() do |socket|
      socket.send(method) if socket.respond_to?(method)
    end
  end
end