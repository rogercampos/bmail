class EmailListView < BaseView
  def initialize(controller)
    @controller = controller
  end

  # Actually put the graphics into the screen. May be called from the Layout to
  # redraw the same things (no data changed) but to adapt to a new screen
  # disposition (outside layout reescaled, maybe)
  def update_screen
    @emails.each_with_index do |email, i|
      shout 0, 10 + i, email.subject
    end
  end
end
