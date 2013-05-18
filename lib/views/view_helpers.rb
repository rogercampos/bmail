# encoding: utf-8
module ViewHelpers
  def nice_email_date(email)
    if email.date.to_time > Date.today.beginning_of_day
      email.date.to_time.strftime("%R")
    else
      email.date.to_time.strftime("%d/%m")
    end
  end

  def draw_box(ox, oy, width, height)
    shout_without_scroll ox+1, oy, "─" * (width-1)
    shout_without_scroll ox+1, oy+height-1, "─" * (width-1)

    (height-2).times do |ly|
      shout_without_scroll ox, oy+ly+1, "│"
      shout_without_scroll ox+width-1, oy+ly+1, "│"
    end

    shout_without_scroll ox, oy, "┌"
    shout_without_scroll ox+width-1, oy, "┐"
    shout_without_scroll ox, oy+height-1, "└"
    shout_without_scroll ox+width-1, oy+height-1, "┘"
  end
end
