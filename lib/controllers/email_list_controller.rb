class EmailListController < BaseController
  def render
    @view.draw emails: emails, current_email: @bmail.current_email
  end

  def emails
    @emails ||= @bmail.account.inbox.emails.reverse[0..15]
  end
end
