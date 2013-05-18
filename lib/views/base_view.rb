class BaseView
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

  def shout(x, y, str)
    setpos y+1, x+1
    addstr str
  end
end
