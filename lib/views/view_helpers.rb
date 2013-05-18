# encoding: utf-8
module ViewHelpers
  BOX_CHARS = {
    simple: {
      vertical: "│",
      horizontal: "─",
      top_left: "┌",
      top_right: "┐",
      bottom_left: "└",
      bottom_right: "┘"
    },
    double: {
      vertical: "║",
      horizontal: "═",
      top_left: "╔",
      top_right: "╗",
      bottom_left: "╚",
      bottom_right: "╝"
    }
  }

  def nice_email_date(email)
    if email.date.to_time > Date.today.beginning_of_day
      email.date.to_time.strftime("%R")
    else
      email.date.to_time.strftime("%d/%m")
    end
  end

  def draw_box(ox, oy, width, height, opts = {})
    opts.reverse_merge! type: :simple

    type = opts[:type]
    color = opts[:color]

    shout_without_scroll ox+1, oy, BOX_CHARS[type][:horizontal] * (width-1), color: color
    shout_without_scroll ox+1, oy+height-1, BOX_CHARS[type][:horizontal] * (width-1), color: color

    (height-2).times do |ly|
      shout_without_scroll ox, oy+ly+1, BOX_CHARS[type][:vertical], color: color
      shout_without_scroll ox+width-1, oy+ly+1, BOX_CHARS[type][:vertical], color: color
    end

    shout_without_scroll ox, oy, BOX_CHARS[type][:top_left], color: color
    shout_without_scroll ox+width-1, oy, BOX_CHARS[type][:top_right], color: color
    shout_without_scroll ox, oy+height-1, BOX_CHARS[type][:bottom_left], color: color
    shout_without_scroll ox+width-1, oy+height-1, BOX_CHARS[type][:bottom_right], color: color
  end
end
