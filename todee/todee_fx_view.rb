require 'rubygems'
require 'fox16'

include Fox

class TodeeFXListener < TodeeListenerBase
  def start(environment, code)
    @instructions_executed = 0
    
    @application = FXApp.new('Todee', 'Todee')
    @window = TodeeFXWindow.new(@application, environment, code, self)
    @application.create()
    @application.run()
    
    return @instructions_executed
  end
  
  def stop()
  end
  
  def pre_execute(row, column, codepoint)
    @window.new_position(row, column)
    @instructions_executed += 1
  end
  
  def read_socket(given_address, ref_level, actual_address, value)
    @window.read_socket(actual_address, value) if actual_address
  end
  
  def write_socket(given_address, ref_level, actual_address, value)
    @window.write_socket(actual_address, value)
  end
end

class TodeeFXWindow < FXMainWindow
  def initialize(app, environment, code, listener)
    @app = app
    @environment = environment
    @code = code
    
    @last_pos = [0, 0]
    @cp_size = 7
    @socket_access = {}
    @delay = 8

    super(app, 'Todee', :width => 800, :height => 600)
    
    @frame = FXHorizontalFrame.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_FILL_Y,
                                   :padLeft => 0, :padRight => 0, :padTop => 0, :padBottom => 0)

    @canvas = FXCanvas.new(@frame, :opts => LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
    @canvas.connect(SEL_PAINT) do |sender, sel, event|
      FXDCWindow.new(@canvas, event) do |dc|
        dc.foreground = "black"
        dc.fillRectangle(event.rect.x, event.rect.y, event.rect.w, event.rect.h)
        draw_code(dc)
      end
    end
    
    @canvas.connect(SEL_MOTION) do |sender, sel, event|
      row, col = event.win_x / @cp_size, event.win_y / @cp_size
      if @code[row] and @code[row][col] then
        @codepointinfo.text = @code[row][col].to_s
      else
        @codepointinfo.text = ""
      end
    end

    @sideframe = FXVerticalFrame.new(@frame, LAYOUT_FIX_WIDTH|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT,
                                     :width => 200, :padLeft => 10, :padRight => 10, :padTop => 10, :padBottom => 10)

    @startbutton = FXButton.new(@sideframe, "Start", :opts => FRAME_THICK|FRAME_RAISED|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT)
    @startbutton.connect(SEL_COMMAND) do
        @engine = Engine.new(environment, code, listener)
        timeout = @app.addTimeout(@delay, :repeat => true) do |sender, sel, data|
          if @engine.execute_some(1) == 0 then
            @app.removeTimeout(timeout)
          end
        end
    end
    
    FXLabel.new(@sideframe, "Codepoint hover", nil, LAYOUT_FILL_X, :padTop => 10)
    @codepointinfo = FXLabel.new(@sideframe, "", nil, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, :height => 14)

    FXLabel.new(@sideframe, "Size", nil, LAYOUT_FILL_X, :padTop => 10)
    @sizeSlider = FXSlider.new(@sideframe, nil, 0, SLIDER_HORIZONTAL|SLIDER_INSIDE_BAR|LAYOUT_SIDE_RIGHT|LAYOUT_FILL_X)
    @sizeSlider.connect(SEL_CHANGED) do |sender, sel, event|
      @cp_size = event*2+1
      @canvas.update()
    end
    @sizeSlider.range = 1..5
    @sizeSlider.value = 3
    @sizeSlider.headSize = 20

    FXLabel.new(@sideframe, "Speed", nil, LAYOUT_FILL_X, :padTop => 10)
    @speedSlider = FXSlider.new(@sideframe, nil, 0, SLIDER_HORIZONTAL|SLIDER_INSIDE_BAR|LAYOUT_SIDE_RIGHT|LAYOUT_FILL_X)
    @speedSlider.connect(SEL_CHANGED) do |sender, sel, event|
      @delay = 2**(10-event)
    end
    @speedSlider.range = 0..10
    @speedSlider.value = 7
    @speedSlider.headSize = 20
    
    FXLabel.new(@sideframe, "Socket access", nil, LAYOUT_FILL_X, :padTop => 10)
    @socketframe = FXVerticalFrame.new(@sideframe, LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT,
                                      :padTop => 0, :padLeft => 0, :padRight => 0, :padBottom => 0)
  end
  
  def create()
    super()
    show(PLACEMENT_SCREEN)
  end
  
  def new_position(row, col)
    dc = FXDCWindow.new(@canvas)
    draw_code_point(dc, @last_pos[1], @last_pos[0])
    
    dc.foreground = "white"
    dc.fillRectangle(row*@cp_size, col*@cp_size, @cp_size, @cp_size)
    dc.end()
    @app.flush()
    
    @last_pos = [col, row]
  end
  
  def read_socket(address, value)
    prev = @socket_access[address]
    if prev then
      label = prev[0]
      writevalue = prev[2]
    else
      label = create_new_socket_label(address)
    end
    @socket_access[address] = [label, value, writevalue]
    label.text = "R#{value}, W#{writevalue}"
  end
  
  def write_socket(address, value)
    prev = @socket_access[address]
    if prev then
      label = prev[0]
      readvalue = prev[1]
    else
      label = create_new_socket_label(address)
    end
    @socket_access[address] = [label, readvalue, value]
    label.text = "R#{readvalue}, W#{value}"
  end
  
  def create_new_socket_label(address)
    address_frame = FXHorizontalFrame.new(@socketframe, LAYOUT_FILL_X, :padTop => 0, :padLeft => 0, :padRight => 0, :padBottom => 0)
    address_label = FXLabel.new(address_frame, "#{@environment.socket(address).class.to_s.sub('Socket', '')}(#{address})", :padTop => 0, :padLeft => 0, :padRight => 0, :padBottom => 0)
    label = FXLabel.new(address_frame, "", nil, LAYOUT_FILL_X, :padTop => 0, :padLeft => 0, :padRight => 0, :padBottom => 0)
    address_frame.create()
    address_frame.show()
    address_label.create()
    address_label.show()
    label.create()
    label.show()
    label
  end
  
  def draw_code(dc)
    @code.each_index do |row|
      @code[row].each_index do |col|
        draw_code_point(dc, row, col)
      end
    end
  end
  
  def draw_code_point(dc, row, col)
    instr = @code[row][col].instruction_symbol
    dc.foreground = case instr
    when :NOP
       "black"
    when :TNL, :TNR, :TUR
      "darkgreen"
    when :CAL, :JMP, :RET, :DRP
      "darkred"
    when :STP
      "red"
    else
      "darkgray"
    end
    dc.fillRectangle(row*@cp_size, col*@cp_size, @cp_size, @cp_size)
    
    if @cp_size > 4 then
      case instr
      when :TNL, :TNR
        drawturnlr(dc, row*@cp_size, col*@cp_size, instr)
      when :TUR
        drawturn(dc, row*@cp_size, col*@cp_size, @code[row][col].arguments[0])
      end
    end
  end
  
  def drawturnlr(dc, x, y, instr)
    dc.foreground = "black"
    case instr
    when :TNL
      dc.drawLines([FXPoint.new(x+3, y+1), FXPoint.new(x+@cp_size-2, y+1), FXPoint.new(x+@cp_size-2, y+@cp_size-3), FXPoint.new(x+@cp_size-3, y+@cp_size-4)])
      dc.drawLines([FXPoint.new(x+@cp_size-4, y+@cp_size-2), FXPoint.new(x+1, y+@cp_size-2), FXPoint.new(x+1, y+2), FXPoint.new(x+2, y+3)])
    when :TNR
      dc.drawLines([FXPoint.new(x+1, y+3), FXPoint.new(x+1, y+@cp_size-2), FXPoint.new(x+@cp_size-3, y+@cp_size-2), FXPoint.new(x+@cp_size-4, y+@cp_size-3)])
      dc.drawLines([FXPoint.new(x+@cp_size-2, y+@cp_size-4), FXPoint.new(x+@cp_size-2, y+1), FXPoint.new(x+2, y+1), FXPoint.new(x+3, y+2)])
    end
  end
  
  def drawturn(dc, x, y, arg)
    if arg.ref_level == 0 then
      dc.foreground = "black"
      case arg.value % 4
      when 0
        dc.drawLines([FXPoint.new(x+@cp_size/2, y+1), FXPoint.new(x+@cp_size-2, y+@cp_size/2), FXPoint.new(x+@cp_size/2, y+@cp_size-2)])
      when 1
        dc.drawLines([FXPoint.new(x+1, y+@cp_size/2), FXPoint.new(x+@cp_size/2, y+@cp_size-2), FXPoint.new(x+@cp_size-2, y+@cp_size/2)])
      when 2
        dc.drawLines([FXPoint.new(x+@cp_size/2, y+@cp_size-2), FXPoint.new(x+1, y+@cp_size/2), FXPoint.new(x+@cp_size/2, y+1)])
      when 3
        dc.drawLines([FXPoint.new(x+@cp_size-2, y+@cp_size/2), FXPoint.new(x+@cp_size/2, y+1), FXPoint.new(x+1, y+@cp_size/2)])
      end
    end
  end
end
