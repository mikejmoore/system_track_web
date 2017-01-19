require_relative "../base_page"
require_relative "../../../../lib/view/service_location_utils"

class ServicesLocationsTable < ObjectView::Div
  include SystemTrack
  include ObjectView
  include ServiceLocationsUtils
  
  SERVICE_COLUMN_WIDTH = "70px"
  #SERVICE_COLUMN_WIDTH = "200px"
  MACHINE_NAME_COLUMN_WIDTH = "100px"
  
  SELECTED_GRAPHIC_WIDTH = "60px"
  SELECTED_GRAPHIC_HEIGHT = "14px"
  
  
  def initialize(network, services, options = {})
    super()
    report_style = (options[:report] == true)
    @network = network
    @services = services
    if (network['machines'].length > 0)
      service_hash = find_service_environments_hash(network, @services)
#      @service_hash_keys = service_hash.keys.sort[0..1]
      @service_hash_keys = service_hash.keys.sort
      raise "Could not find service environments" if (!service_hash)
      table_parent = self
      if (report_style)
      else
        outer_div = self.add Div.new
        outer_div.css_class = "wideTableOuter"
        inner_div = outer_div.add Div.new
        inner_div.css_class = "wideTableInner"
        table_parent = inner_div
      end
      
      table = table_parent.add Table.new
      table.id = "machine_service_table_#{network['id']}"
      if (report_style)
        table.css_class = "wideReportTable"
        table.style = {margin_bottom: "15px", width: "1%"}
      else
        table.css_class = "wideTable"
        table.style = {margin_bottom: "5px"}
      end
      
      head_row = table.row
      table_header_row(head_row, service_hash)
      network['machines'].each do |machine|
        div = Div.new(machine['ip_address'])
        machine_row = table.row()
        row_head = machine_row.add THeadCell.new
        row_head.add(machine['ip_address'])
        row_head.style = {border_left: "solid 1px black", border_right: "solid 1px gray"}
        if (network['machines'].last == machine)
          row_head.style[:border_bottom] = "solid 1px black"
        end
        if (network['machines'].first == machine)
          row_head.style[:border_top] = "solid 1px black"
        end
        
        
        @service_hash_keys.each do |key|
          column_service = service_hash[key][:service]
          column_environment = service_hash[key][:environment]
          
          div = Div.new()
          div.id = "div_#{machine['id']}_#{column_service['id']}_#{column_environment['id']}"
          div.style = {cursor: 'pointer', width: '100%', text_align: "center", margin: '0 auto'}
          cell = TCell.new 
          cell.add div
          cell.attr('align', "center")
          cell.attr('onclick', "toggleMachineService(#{machine['id']}, #{column_service['id']}, '#{column_environment['id']}');")
          cell.style = {width: SERVICE_COLUMN_WIDTH}

          if (@service_hash_keys.last == key)
            cell.style[:border_right] = "solid 1px black"
          end
          
          if (network['machines'].last == machine)
            cell.style[:border_bottom] = "solid 1px black"
          end
            
          machine_row.add cell
          
          machine_services = column_service['machine_services']
          match = machine_services.find {|s| 
            (s['machine_id'] == machine['id']) && (s['environment_id'] == column_environment['id'])
          }

          if (match)
            circle = div.add Div.new
            circle.style = {width: SELECTED_GRAPHIC_WIDTH, height: SELECTED_GRAPHIC_HEIGHT, background: "green", border_radius: "6px", cursor: 'pointer'}
          else
            circle = div.add Div.new
            circle.style = {width: SELECTED_GRAPHIC_WIDTH, height: SELECTED_GRAPHIC_HEIGHT, cursor: 'pointer'}
          end
        end
      end
    end
  end
  
  
  def table_header_row(row, service_hash)
    blank_div = Div.new
    net_span = blank_div.add Span.new(@network['code'])
    net_span.style = {font_size: '17px', color: '#aaaacc'}
  #  blank_div.style = { width: MACHINE_NAME_COLUMN_WIDTH}
    cell = row.head_cell
    cell.add blank_div
    cell.style = {border_top: 'none', border_left: 'none', border_top: "none"}
    top_row_elements = [blank_div]
    @service_hash_keys.each do |key|
      service = service_hash[key][:service]
      environment = service_hash[key][:environment]
      div = Div.new()
      env_head = div.add Span.new(environment['code'].upcase)
      env_head.style = {color: "#111166", font_size: "14px", font_weight: "bold"}
      div.add "<br/>#{service['name']}"
      
      cell = row.cell
      cell.add div
      cell.style = {background: '#BDB76B', color: 'black', width: SERVICE_COLUMN_WIDTH, border_top: "1px solid black"}
      if (@service_hash_keys.last == key)
        cell.style[:border_right] = "solid 1px black"
      end
      
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
