require 'todee/todee_sockets'
require 'todee/todee_listener_base'

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
  
  def deref_read(address, ref_level, listener = TodeeListenerBase::NULL)
    orig_address = address
    orig_ref_level = ref_level
    final_address = nil

    until ref_level == 0 do
      final_address = address
      address = read(address.to_i)
      ref_level -= 1
    end
    
    value = address.to_i
    listener.read_socket(orig_address, orig_ref_level, final_address, value)
    return value
  end
  
  def deref_write(address, ref_level, value, listener = TodeeListenerBase::NULL)
    orig_address = address
    orig_ref_level = ref_level
    
    if address and ref_level > 0 then
      until ref_level == 1 do
        address = read(address)
        return if not address
        ref_level -= 1
      end
    
      listener.write_socket(orig_address, orig_ref_level, address, value)
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