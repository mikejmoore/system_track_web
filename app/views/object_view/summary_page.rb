require_relative "./base_page"
require_relative "./machine/machine_entry_form"
require_relative "./machine/machine_list_table"
require_relative "./network/network_entry_form"
require_relative "./network/network_list_table"

class SummaryPage < BasePage
  
  def initialize(session, options = {})
    super(session, options)
    self.body.add JavascriptFile.new("/javascripts/machine.js")
    self.body.add JavascriptFile.new("/javascripts/network.js")
    
    create_main_menu(session, :machines)
    create_add_machine_section()
    create_machine_list()
  end
  
  
  def create_add_machine_section()
    add_section = @right_content.add Div.new
    add_section.id = "add_section"
    
    add_button = add_section.add Link.new "/v1/machines/edit_machine", "Add Machine"
    add_button.css_class = "waves-effect waves-light btn"
    add_button.id = "add_machine_button"
  end

  
  def create_machine_list()
    table_holder = @right_content.add Div.new
    table_holder.style = {background: "white", width: "90%", border_radius: "5px", padding_right: "20px"}
    table_holder.id = "machine_list_holder"
    Rails.logger.info("Summary page, current user: #{@current_user}")
    table = table_holder.add MachineListTable.new(@session, @current_user.account_id)
  end

  
end