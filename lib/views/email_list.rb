# encoding: utf-8
class EmailListView < BaseView
  def initialize(*)
    super
    enable_scroll!
  end

  # Actually put the graphics into the screen. May be called from the Layout to
  # redraw the same things (no data changed) but to adapt to a new screen
  # disposition (outside layout reescaled, maybe)
  def update_screen
    draw_box 0, 0, @width, @height

    @emails.each_with_index do |email, i|
      shout 1, 1 + 4*i, email[:from].display_names.first
      reverse_shout @width-1, 2 + 4*i, nice_email_date(email)
      shout 1, 3 + 4*i, email.subject, truncation_threshold: @width-3

      if email == @current_email
        draw_box 0, 4*i, @width, 5, type: :double, color: Curses::COLOR_GREEN
      else
        shout 1, 4 + 4*i, "─" * (@width-2)
      end
    end
  end
end
