require_relative "../base_page"
require_relative "./service_entry_form"
require_relative "./service_list_table"


class ServiceSummaryPage < BasePage
  include SystemTrack
  
  def initialize(session, options = {})
    super(session, options)
    self.body.add JavascriptFile.new("/javascripts/service.js")
    
    create_main_menu(session, :services)

    create_add_section()

    create_list()
  end
  
  

  def create_add_section()
    add_section = @right_content.add Div.new
    add_section.id = "add_service_section"
    
    add_button = add_section.add Button.new "Add Service"
    add_button.css_class = "waves-effect waves-light btn"
    add_button.id = "add_service_button"
    add_button.on_click = "showAddServiceForm()"
    
    add_form_holder = add_section.add Div.new
    add_form_holder.id = "service_edit_form_holder"
  end


  def create_list()
    table_holder = @right_content.add Div.new
    table_holder.style = {background: "white", width: "90%", border_radius: "5px", padding_right: "20px"}
    table_holder.id = "service_list_holder"
    table = table_holder.add ServiceListTable.new(@session, @current_user.account_id)
  end
  
end