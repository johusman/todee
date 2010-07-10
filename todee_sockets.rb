class StackSocket
  def initialize()
    @stack = []
  end
    
  def read()
    @stack.pop()
  end
  
  def write(value)
    @stack.push(value)
  end
end

class MemorySocket
  def read()
    @value
  end
  
  def write(value)
    @value = value
  end
end

class NullSocket
  def read()
    nil
  end
  
  def write(value)
  end
end

class StdoutSocket
  def read()
    nil
  end
  
  def write(value)
    $stdout.write(value.to_i.chr)
    $stdout.flush
  end
end

class SocketManager
  def initialize()
    @sockets = []
  end
  
  def register_socket(socket, address)
    @sockets[address.to_i] = socket
  end
  
  def socket(address)
    @sockets[address.to_i] or NullSocket.new
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