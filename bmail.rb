# encoding: utf-8
#require 'bundler/setup'

require 'mail'
require 'curses'

require 'active_support/core_ext/date/calculations'

require_relative 'lib/controllers/base_controller'
require_relative 'lib/controllers/email_list_controller'
require_relative 'lib/controllers/email_show_controller'

require_relative 'lib/models/account'
require_relative 'lib/models/mailbox'
require_relative 'lib/models/message'

require_relative 'lib/views/base_view'
require_relative 'lib/views/email_list'
require_relative 'lib/views/email_show'


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

class Runner
  include Curses

  def initialize
    @bmail = Bmail.new

    trap("TERM") {|sig| onsig(sig) }

    window = init_screen
    start_color
    cbreak
    nonl
    noecho

    init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
    init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)

    email_list_c = EmailListController.new(@bmail)
    email_list_c.view = EmailListView.new(window, email_list_c, origin: [1, 1], width: 37, height: 60)

    email_show_c = EmailShowController.new(@bmail)
    email_show_c.view = EmailShowView.new(window, email_show_c, origin: [38, 1], width: 100, height: 60)


    loop do
      email_list_c.render
      email_show_c.render

      refresh
      sleep 1
    end
  end

  def onsig(sig)
    close_screen
    exit sig
  end
end
