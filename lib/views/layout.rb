class Views::Console::Layout
  def initialize(window)
    @window = window
    # Initialize all views
    build_layout
  end

  def update_screen
    views.each(&:update_screen)
  end

  def views
    @views ||= []
  end

  private

  def build_layout
    views << Views::EmailList.new(30)
    views << Views::EmailDetail.new(70)
  end
end
