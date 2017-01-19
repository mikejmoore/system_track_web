require_relative "../base_page"
require_relative "./services_locations_all_tables"

class ServicesLocationsPage < BasePage
  include SystemTrack
  SERVICE_COLUMN_WIDTH = "80px"
  MACHINE_NAME_COLUMN_WIDTH = "120px"
  
  def initialize(session, options = {})
    super(session, options)
    
    add_java_script_file("/javascripts/machine.js")
    create_main_menu(session, :machines) if (@current_user)

    if (options[:report] != true)
      @right_content.add Link.new("/reports/service_location?report=true", "Report")
    end
    
    row = @right_content.add Div.new
    row.add ServicesLocationsAllTables.new(session, options)
  end
  
end