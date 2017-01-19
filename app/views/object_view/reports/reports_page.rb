require_relative "../base_page"

class ReportsPage < BasePage
  include SystemTrack
  
  def initialize(session, options = {})
    super(session, options)
    create_main_menu(session, :reports) if (@current_user)
    
    row = @right_content.add Div.new
    row.css_class = "row"
    
    row.add add_link("/reports/service_location", "Services Locations")
    # row.add add_link("/reports/service_location", "Services Locations")
    # row.add add_link("/reports/service_location", "Services Locations")
    # row.add add_link("/reports/service_location", "Services Locations")
  end
  
  def add_link(address, label)
    div = Div.new
    div.css_class = "col s2 z-depth-2"
    link = div.add Link.new "/reports/service_location", "Services Locations"
    link.style = {width: "200px", height: "200px"}
    return div
  end

  
end