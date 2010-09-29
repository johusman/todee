class TodeeListenerBase
  def pre_execute(row, column, codepoint)
  end
  
  def post_execute(row, column, codepoint)
  end
  
  def read_socket(given_address, ref_level, actual_address, value)
  end
  
  def write_socket(given_address, ref_level, actual_address, value)
  end
  
  NULL = TodeeListenerBase.new
end
