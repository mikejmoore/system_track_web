require_relative "./base_page"

class HomePage < BasePage
  include 
  
  def initialize(session, options = {})
    super(session, options)
    create_main_menu(session, :about) if (@current_user)
  end
  
end