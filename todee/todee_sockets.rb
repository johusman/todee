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
  def initialize()
    @value = nil
  end

  def read()
    defined?(@value) ? @value : nil
  end
  
  def write(value)
    @value = value
  end
end

class ScopeMemorySocket < MemorySocket
  def initialize()
    @stack = []
  end
  
  def push_call()
    
    @stack.push(defined?(@value) ? @value : nil)
  end
  
  def pop_call()
    @value = @stack.pop() if @stack.size > 0
  end
  
  def drop_call()
    @stack.pop()
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
    if value.to_i > 0 then
        $stdout.write(value.to_i.chr)
        $stdout.flush
    end
  end
end

# To be done...
class NetworkOutSocket
end

class NetworkInSocket
end
