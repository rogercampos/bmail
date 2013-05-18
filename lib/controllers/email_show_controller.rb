class EmailShowController < BaseController
  def render
    @view.draw email: @bmail.account.inbox.emails.last
  end
end
