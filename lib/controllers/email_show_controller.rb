class EmailShowController < BaseController
  def render
    @view.draw email: email
  end

  def email
    @bmail.current_email
  end
end
