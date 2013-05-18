# Decides who will process the user input
class Router
  def initialize(controllers)
    @controllers = controllers
  end

  def route(key_combination)
    # Lookup to which controller this key combination belongs
    controller.process_request(key_combination)
  end
end
