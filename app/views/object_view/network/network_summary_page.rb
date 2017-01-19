require_relative "../base_page"
require_relative "./network_entry_form"
require_relative "./network_list_table"


class NetworkSummaryPage < BasePage
  include SystemTrack
  
  def initialize(session, options = {})
    super(session, options)
    self.body.add JavascriptFile.new("/javascripts/network.js")
    
    create_main_menu(session, :networks)

    create_add_network_section()

    Service_list()
  end


  def create_add_network_section()
    add_section = @right_content.add Div.new
    add_section.id = "add_network_section"
    
    add_button = add_section.add Button.new "Add Network"
    add_button.css_class = "waves-effect waves-light btn"
    add_button.id = "add_network_button"
    add_button.on_click = "showAddNetworkForm()"
    
    add_form_holder = add_section.add Div.new
    add_form_holder.id = "network_edit_form_holder"
  end


  def Service_list()
    table_holder = @right_content.add Div.new
    table_holder.style = {background: "white", width: "90%", border_radius: "5px", padding_right: "20px"}
    table_holder.id = "network_list_holder"
    table = table_holder.add NetworkListTable.new(@session, @current_user.account_id)
  end
  
end