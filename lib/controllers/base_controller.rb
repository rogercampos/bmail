class BaseController
  attr_accessor :view

  def initialize(bmail)
    @bmail = bmail
  end
end
