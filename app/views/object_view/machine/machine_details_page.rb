require_relative "../base_page"
require_relative "./machine_nic_table"


class MachineDetailsPage < BasePage
  include SystemTrack
  
  def initialize(session, machine_id, options = {})
    super(session, options)
    self.body.add JavascriptFile.new("/javascripts/machine.js")
    self.body.add JavascriptFile.new("/javascripts/machine_nic.js")
    
    create_main_menu(session, :machines)
    
    # table = @right_content.add Table.new
    # table.style = {width: "100%"}
    main_row = @right_content.add Div.new
    main_row.css_class = "row"
    
    @general_info = main_row.add Div.new
    @general_info.id = "general_info"
    #@general_info.style = {width: "80%"}
    @general_info.css_class = "col s7"
    @general_info.add "<h3 class='section-head'>General Info</h3>"
    
    @right_margin = main_row.add Div.new
    @right_margin.id = "right_margin"
    @right_margin.css_class = "col s5"
    
    machine = MachinesProxy.new.machine(session, machine_id)
    @general_info.add MachineEntryForm.new(session, machine, mode = :view)

    nic_row = @right_margin.add Div.new
    nic_row.css_class = "row"
    nic_header_row = nic_row.add Div.new
    nic_header_row.css_class = "row"
    nic_header_row.add "<h3 class='section-head'>Network Cards</h3>"
    nic_content_row = nic_row.add Div.new
    nic_content_row.css_class = "row"
    nic_content_row.id = "nic_table_holder"
    nic_content_row.add MachineNicTable.new(session, machine)
    
    stat_row = @right_margin.add Div.new
    stat_row.css_class = "row"
    header_row = stat_row.add Div.new "<h3 class='section-head'>Specifications</h3>"
    header_row.css_class = "row"
    content_row = stat_row.add Div.new
    content_row.css_class = "row"
    
    
  end
  
end