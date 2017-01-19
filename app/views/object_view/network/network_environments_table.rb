require_relative "../base_page"
require_relative "../../../../lib/view/service_location_utils"

class ServicesLocationsTable < ObjectView::Div
  include SystemTrack
  include ObjectView
  include ServiceLocationsUtils
  
  SERVICE_COLUMN_WIDTH = "80px"
  MACHINE_NAME_COLUMN_WIDTH = "120px"
  
  def initialize(session, options = {})
    super()
    
    @environments = MachinesProxy.new.environment_list(session)
    @networks = MachinesProxy.new.networks_add_machines(session)
    
    @networks.each do |n| 
      n['padded_address'] = padded_ip(n['address'])
    end
    @networks.sort! {|a, b| a['padded_address'] <=> b['padded_address']}
    @networks.each do |network|
      if (network['machines'].length > 0)
        service_hash = find_service_environments_hash(network, @services)
        raise "Could not find service environments" if (!service_hash)
        outer_div = self.add Div.new
        outer_div.css_class = "wideTableOuter"
        inner_div = outer_div.add Div.new
        inner_div.css_class = "wideTableInner"
        
        table = inner_div.add Table.new
        table.id = "machine_service_table_#{network['id']}"
        table.css_class = "wideTable"
        table.style = {margin_bottom: "5px"}
        head_row = table.row
        table_header_row(head_row, service_hash)
        network['machines'].each do |machine|
          div = Div.new(machine['ip_address'])
#          div.style = { width: MACHINE_NAME_COLUMN_WIDTH}
          
          machine_row = table.row()
          row_head = machine_row.add THeadCell.new
          row_head.add(machine['ip_address'])
          
          service_hash.keys.sort.each do |key|
            column_service = service_hash[key][:service]
            column_environment = service_hash[key][:environment]
            div = Div.new()
            div.id = "div_#{machine['id']}_#{column_service['id']}_#{column_environment['id']}"
            div.style = {cursor: 'pointer'}
            cell = TCell.new 
            cell.add div
            cell.attr('onclick', "toggleMachineService(#{machine['id']}, #{column_service['id']}, '#{column_environment['id']}');")
            machine_row.add cell
            
            machine_services = column_service['machine_services']
            match = machine_services.find {|s| 
              (s['machine_id'] == machine['id']) && (s['environment_id'] == column_environment['id'])
            }

            graphic_height = 14
            graphic_width = 80
            if (match)
              circle = div.add Div.new
              circle.style = {width: "#{graphic_width}px", height: "#{graphic_height}px", background: "green", border_radius: "6px", cursor: 'pointer'}
            else
              circle = div.add Div.new
              circle.style = {width: "#{graphic_width}px", height: "#{graphic_height}px", cursor: 'pointer'}
            end
          end
        end
        # spacer_div = self.add Div.new
        # spacer_div.style = {height: '20px'}
        
        
      end
      
    end
    
    # self.add Javascript.new "
    #   function toggleMachineService(machine_id, service_id) {
    #     alert('Machine Service Toggled: ' + machine_id + ', ' + service_id);
    #   }
    # "
  end
  
  # def find_service_environments_hash(network)
  #   service_hash = {}
  #   network['environments'].each do |environment|
  #     @services.each do |service|
  #       if (service['environments'].find{|e| e['id'] == environment['id']})
  #         service_hash["#{environment['code']}.#{service['code']}"] = {service: service, environment: environment}
  #       end
  #     end
  #   end
  #   return service_hash
  # end
  
  def table_header_row(row, service_hash)
    blank_div = Div.new
  #  blank_div.style = { width: MACHINE_NAME_COLUMN_WIDTH}
    cell = row.head_cell
    cell.add blank_div
    cell.style = {border_top: 'none'}
    top_row_elements = [blank_div]
    service_hash.keys.sort.each do |key|
      service = service_hash[key][:service]
      environment = service_hash[key][:environment]
      div = Div.new("#{service['name']}<br/>#{environment['code'].upcase}")
      # div.style = { transform: 'rotate(90deg)',
      #                     transform_origin: 'left top 0;'}
      cell = row.cell
      cell.add div
      cell.style = {background: '#BDB76B', color: 'black'}
    end
  end
  
  def create_blank_row(network, table, top_row_elements)
    elements = []
#    top_row_elements.each  { elements << "" }
    div = Div.new(network['name'])
    div.style = {padding_top: "5px", padding_left: "5px"}
    elements << div
    
    blank_row = table.row(elements)
    blank_row.children.first.attr("colspan", top_row_elements.length)
    blank_row.children.each {|c| c.style = {background: '#aaaaaa'}}
  end
  
  
end
