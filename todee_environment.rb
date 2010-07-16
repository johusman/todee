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
    socket(address).read()
  end
  
  def write(address, value)
    socket(address).write(value)
  end
  
  def [](address)
    read(address)
  end
  
  def []=(address, value)
    write(address, value)
  end
end