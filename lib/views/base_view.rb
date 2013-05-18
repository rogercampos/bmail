# encoding: utf-8
class BaseView
  include ViewHelpers
  attr_accessor :scroll

  def initialize(window, controller, opts)
    @window = window
    @controller = controller
    @width = opts[:width]
    @height = opts[:height]
    @origin = opts[:origin]
    @scroll = 0
  end

  def enable_scroll!
    @scroll_enabled = true
  end

  def scroll_enabled?
    !!@scroll_enabled
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

  def shout_without_scroll(x, y, str, opts = {})
    shout x, y - @scroll, str, opts
  end

  def shout(x, y, str, opts = {})
    assert_in_frame(x, y)

    if scroll_enabled?
      y = y + @scroll
      # Don't baypass this window limitations because of the scroll.
      return if y < 0 || y >= @height
    end

    # Don't draw outside the real window limits
    return if outside_visible_area?(x, y)

    str = str.force_encoding("UTF-8")
    raise ArgumentError, "cannot be called on multi-line strings" if str.split("\n").size > 1

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

  def outside_visible_area?(x, y)
    x+@origin[0] < 0 || x+@origin[0] >= @window.maxx ||
      y+@origin[1] < 0 || y+@origin[1] >= @window.maxy
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
    if scroll_enabled?
      if x < 0 || x >= @width
        raise ArgumentError, "#{x}x#{y} coordinates are outside the boundaries of this view [#{@width}x#{@height}]"
      end
    else
      if x < 0 || y < 0 || x >= @width || y >= @height
        raise ArgumentError, "#{x}x#{y} coordinates are outside the boundaries of this view [#{@width}x#{@height}]"
      end
    end
  end

  def adjust_str_width(str, width = @width)
    if str.length > width
      "#{str[0..width-2]}…"
    else
      str
    end
  end

  def shout_text(x, y, text)
    i = 0
    text.split("\n").each do |line|
      if line.length < @width-2
        shout x, y+i, line
        i += 1
      else
        TextParser.new(line).split_in_length(@width-2).each do |sub_line|
          shout x, y+i, sub_line
          i += 1
        end
      end
    end
  end
end
