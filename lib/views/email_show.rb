# encoding: utf-8
class EmailShowView < BaseView
  def initialize(*)
    super
    enable_scroll!
  end

  # Actually put the graphics into the screen. May be called from the Layout to
  # redraw the same things (no data changed) but to adapt to a new screen
  # disposition (outside layout reescaled, maybe)
  def update_screen
    draw_box 0, 0, @width, @height
    shout 4, 1, "From: #{@email[:from]}"
    shout 4, 2, "To: #{@email[:to]}"
    shout 4, 3, "CC: #{@email[:cc]}"
    shout 4, 4, "Date: #{@email.date.to_time.strftime("%d/%m/%Y %R")}"
    shout 4, 5, "Subject: #{@email.subject}", bold: true

    shout 1, 7, "-"*(@width-2)

    if @email.text_part
      shout_text 4, 8, @email.text_part.body.decoded
    else
      shout_text 4, 8, "[Text part not present, you can open HTML pressing 'o']"
    end
  end
end

