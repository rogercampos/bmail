# encoding: utf-8
#require 'bundler/setup'

require 'mail'
require 'curses'
require 'tempfile'
require 'launchy'

require 'active_support/core_ext/date/calculations'

require_relative 'lib/controllers/base_controller'
require_relative 'lib/controllers/email_list_controller'
require_relative 'lib/controllers/email_show_controller'

require_relative 'lib/models/account'
require_relative 'lib/models/mailbox'
require_relative 'lib/models/message'

require_relative 'lib/views/view_helpers'
require_relative 'lib/views/base_view'
require_relative 'lib/views/email_list'
require_relative 'lib/views/email_show'


class Bmail
  def initialize
    data = YAML.load_file ".credentials.yml"
    @account = Account.new data['username'], data['password']
    @account.login
    @current_email_pointer = 0
  end

  def account
    @account
  end

  def current_email
    account.inbox.emails.reverse[@current_email_pointer]
  end

  def next
    @current_email_pointer += 1
  end

  def previous
    @current_email_pointer -= 1
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
    init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
    init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_BLACK)
    init_pair(COLOR_WHITE,COLOR_WHITE,COLOR_BLACK)
    init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)

    @controllers = []

    email_list_c = EmailListController.new(@bmail)
    email_list_c.view = EmailListView.new(window, email_list_c, origin: [1, 1], width: 37, height: 60)
    @controllers << email_list_c

    email_show_c = EmailShowController.new(@bmail)
    email_show_c.view = EmailShowView.new(window, email_show_c, origin: [38, 1], width: 100, height: 60)
    @controllers << email_show_c


    loop do
      window.clear
      render

      case getch
      when 'j'
        @bmail.next
      when 'k'
        @bmail.previous
      when 's'
        email_show_c.view.scroll += 3
      when 'w'
        email_show_c.view.scroll -= 3
      when 'o'
        open_html_email(@bmail.current_email)
      end

      window.noutrefresh
    end
  end

  def render
    @controllers.each(&:render)
  end

  def open_html_email(email)
    tempfile = Tempfile.new([email.subject, ".html"])
    tempfile.write email.html_part.body.to_s
    tempfile.flush
    Launchy.open "file://#{tempfile.path}"
  end

  def onsig(sig)
    close_screen
    exit sig
  end
end
