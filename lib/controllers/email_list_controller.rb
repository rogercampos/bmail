class EmailListController < BaseController
  def render
    @view.draw emails: @bmail.account.inbox.emails.reverse[0..10]
  end
end
