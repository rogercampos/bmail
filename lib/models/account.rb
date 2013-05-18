require 'net/imap'
require 'net/smtp'

class Account
  def initialize(username, password)
    @username = username
    @password = password
    @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
  end

  def login
    res = @imap.login(@username, @password)
    @logged_in = true if res && res.name == 'OK'
  end

  def logged_in?
    !!@logged_in
  end

  def logout
    if logged_in?
      res = @imap.logout
      @logged_in = false if res && res.name == 'OK'
    end
  end

  # Shutdown socket and disconnect
  def disconnect
    logout if logged_in?
    @imap.disconnect unless @imap.disconnected?
  end

  def perform
    login
    yield
  ensure
    logout
  end


  ###########################
  #  READING EMAILS
  #
  #  gmail.inbox
  #  gmail.label('News')
  #
  ###########################

  def inbox
    in_label('inbox')
  end

  def create_label(name)
    imap.create(name)
  end

  # List the available labels
  def labels
    (imap.list("", "%") + imap.list("[Gmail]/", "%")).inject([]) { |labels,label|
      label[:name].each_line { |l| labels << l }; labels }
  end

  # gmail.label(name)
  def label(name)
    mailboxes[name] ||= Mailbox.new(self, name)
  end
  alias :mailbox :label

  # don't mark emails as read on the server when downloading them
  attr_accessor :peek

  ###########################
  #  MAKING EMAILS
  #
  #  gmail.generate_message do
  #    ...inside Mail context...
  #  end
  #
  #  gmail.deliver do ... end
  #
  #  mail = Mail.new...
  #  gmail.deliver!(mail)
  ###########################
  def generate_message(&block)
    mail = Mail.new(&block)
    mail.delivery_method(*smtp_settings)
    mail
  end

  def deliver(mail=nil, &block)
    mail = Mail.new(&block) if block_given?
    mail.delivery_method(*smtp_settings)
    mail.from = @username unless mail.from
    mail.deliver!
  end


  def in_mailbox(mailbox, &block)
    if block_given?
      mailbox_stack << mailbox
      unless @selected == mailbox.name
        imap.select(mailbox.name)
        @selected = mailbox.name
      end
      value = block.arity == 1 ? block.call(mailbox) : block.call
      mailbox_stack.pop
      # Select previously selected mailbox if there is one
      if mailbox_stack.last
        imap.select(mailbox_stack.last.name)
        @selected = mailbox.name
      end
      return value
    else
      mailboxes[mailbox] ||= Mailbox.new(self, mailbox)
    end
  end
  alias :in_label :in_mailbox

  ###########################
  #  Other...
  ###########################
  def inspect
    "#<Gmail:#{'0x%x' % (object_id << 1)} (#{@username}) #{'dis' if !logged_in?}connected>"
  end

  # Accessor for @imap, but ensures that it's logged in first.
  def imap
    unless logged_in?
      login
      at_exit { logout } # Set up auto-logout for later.
    end
    @imap
  end


  private

  def mailboxes
    @mailboxes ||= {}
  end

  def mailbox_stack
    @mailbox_stack ||= []
  end

  def domain
    @username.split('@')[0]
  end

  def smtp_settings
    [:smtp, {:address => "smtp.gmail.com",
    :port => 587,
    :domain => domain,
    :user_name => @username,
    :password => @password,
    :authentication => 'plain',
    :enable_starttls_auto => true}]
  end
end
