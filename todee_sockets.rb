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

class QueueSocket
  def initialize()
    @queue = []
  end
  
  def read()
    @queue.pop()
  end
  
  def write(value)
    @queue.unshift(value)
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

class StdinSocket
  def read()
    return $stdin.getc
  end
  
  def write(value)
  end
end

class StdioSocket
  def read()
    return $stdin.getc
  end
  
  def write(value)
    $stdout.write(value.to_i.chr)
    $stdout.flush
  end
end

# To be done...
class NetworkOutSocket
end

class NetworkInSocket
end
