# encoding: utf-8
#require 'bundler/setup'

require 'mail'
require 'curses'

require_relative 'lib/controllers/base_controller'
require_relative 'lib/controllers/email_list_controller'

require_relative 'lib/models/account'
require_relative 'lib/models/mailbox'
require_relative 'lib/models/message'

require_relative 'lib/views/base_view'
require_relative 'lib/views/email_list'


class Bmail
  def initialize
    data = YAML.load_file ".credentials.yml"
    @account = Account.new data['username'], data['password']
    @account.login
  end

  def account
    @account
  end
end

bmail = Bmail.new

include Curses

def onsig(sig)
  close_screen
  exit sig
end

trap("TERM") {|sig| onsig(sig) }


window = init_screen
cbreak
nonl
noecho


email_list_c = EmailListController.new(bmail)
email_list_c.view = EmailListView.new(email_list_c)


#layout = Views::Console::Layout.new(window)

while true
  email_list_c.render

  a = getch
  refresh
  sleep 0.4
end



# last_msg = @account.inbox.emails.last
# last_msg.text_part.body.decoded
# last_msg.date
# last_msg.subject
# last_msg.to
# last_msg.from
# last_msg.cc
# last_msg.bcc
