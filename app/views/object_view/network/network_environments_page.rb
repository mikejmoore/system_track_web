require_relative "../base_page"
require_relative "./network_environments_table"

class ServicesLocationsPage < BasePage
  include SystemTrack
  SERVICE_COLUMN_WIDTH = "80px"
  MACHINE_NAME_COLUMN_WIDTH = "120px"
  
  def initialize(session, options = {})
    super(session, options)

    self.body.add JavascriptFile.new("/javascripts/machine.js")

    # self.head.add "
    # <style type='text/css'>
    #   .machineServicesTable {
    #       background-color:#FFFFE0;
    #       border-collapse:collapse;
    #       color:#000;
    #       font-size:12px;
    #     }
    #   .machineServicesTable th {
    #       background-color:#BDB76B;
    #       color:white;
    #       width:50%;
    #       border-left:1px dotted #BDB76B;
    #     }
    #   .machineServicesTable td, .myOtherTable th { padding:3px; border:0; }
    #   .machineServicesTable td {
    #         border-bottom:1px dotted #BDB76B;
    #         border-left:1px dotted #BDB76B;
    #       }
    # </style>
    # "
    #
    create_main_menu(session, :networks) if (@current_user)
    
    row = @right_content.add Div.new
    row.add NetworkEnvironmentsTable.new(session)
  end
  
  
end