# encoding: utf-8
class BaseView
  def initialize(window, controller, opts)
    @window = window
    @controller = controller
    @width = opts[:width]
    @height = opts[:height]
    @origin = opts[:origin]
  end

  # The controller tells us to draw a new version of this view
  def draw(data)
    data.each do |k, v|
      instance_variable_set "@#{k}", v
    end

    update_screen
  end

  def update_screen
    raise NotImplementedError
  end

  def shout(x, y, str, opts = {})
    assert_in_frame(x, y)

    attrs = []
    attrs << Curses::A_BOLD if opts[:bold]
    attrs << Curses::A_UNDERLINE if opts[:underline]
    attrs << Curses::A_BLINK if opts[:blink]
    attrs << Curses.color_pair(opts[:color]) if opts[:color]

    with_attrs(attrs) do
      @window.setpos y+@origin[1], x+@origin[0]
      @window.addstr adjust_str_width(str.to_s, opts[:truncation_threshold] || @width)
    end
  end

  def with_attrs(attrs)
    @window.attrset([attrs].flatten.inject{|res, value| res | value}) unless attrs.empty?
    yield
    @window.attrset(Curses::A_NORMAL)
  end

  def reverse_shout(x, y, str)
    shout x - str.length, y, str
  end

  def assert_in_frame(x, y)
    if x < 0 || y < 0 || x >= @width || y >= @height
      raise ArgumentError, "#{x}x#{y} coordinates are outside the boundaries of this view [#{@width}x#{@height}]"
    end
  end

  def adjust_str_width(str, width = @width)
    if str.length > width
      "#{str[0..width-2]}…"
    else
      str
    end
  end

  def nice_email_date(email)
    if email.date.to_time > Date.today.beginning_of_day
      email.date.to_time.strftime("%R")
    else
      email.date.to_time.strftime("%d/%m")
    end
  end

  def draw_box(ox, oy, width, height)
    shout ox+1, oy, "─" * (width-1)
    shout ox+1, oy+height-1, "─" * (width-1)

    (height-2).times do |ly|
      shout ox, oy+ly+1, "│"
      shout ox+width-1, oy+ly+1, "│"
    end

    shout ox, oy, "┌"
    shout ox+width-1, oy, "┐"
    shout ox, oy+height-1, "└"
    shout ox+width-1, oy+height-1, "┘"
  end

  def shout_text(x, y, text)
    text.split("\n").each.with_index do |line, i|
      shout x, y+i, line
    end
  end
end
