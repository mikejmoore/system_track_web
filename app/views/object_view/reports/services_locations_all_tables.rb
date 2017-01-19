require_relative "../base_page"
require_relative "../../../../lib/view/service_location_utils"
require_relative "./services_locations_table"

class ServicesLocationsAllTables < ObjectView::Div
  include SystemTrack
  include ObjectView
  include ServiceLocationsUtils
  
  SERVICE_COLUMN_WIDTH = "80px"
  MACHINE_NAME_COLUMN_WIDTH = "120px"
  
  def initialize(session, options = {})
    super()
    
    @services = MachinesProxy.new.service_list(session)
    @networks = MachinesProxy.new.networks_add_machines(session)
    
    @networks.each do |n| 
      n['padded_address'] = padded_ip(n['address'])
    end
    @networks.sort! {|a, b| a['padded_address'] <=> b['padded_address']}
    @networks.each do |network|
      if (network['machines'].length > 0)
        self.add ServicesLocationsTable.new(network, @services, options)
      end
    end
  end
end
