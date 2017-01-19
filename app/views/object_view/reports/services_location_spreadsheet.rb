require_relative './services_locations_table_base'

class ServicesLocationSpreadsheet < ServicesLocationsTableBase
  
  def initialize(workbook, network, services)
    @workbook = workbook
    @services = services
    @sheet = @workbook.create_worksheet name: "#{network['code']} Services"
    @row_index = 1
    @machine_label_format = Spreadsheet::Format.new color: :black, weight: :bold, size: 12

    @no_service_format = Spreadsheet::Format.new :color=> :black, :pattern_fg_color => :white, :pattern => 1
    @has_service_format = Spreadsheet::Format.new :color=> :black, :pattern_fg_color => :gray, :pattern => 1
    
    super(network, services)
  end
  
  def make_header_row(service_envs)
    head_format = Spreadsheet::Format.new color: :black, weight: :bold, size: 12, text_wrap: true
    @sheet.row(0).default_format = head_format
    @sheet.row(0).push "Machine"
    @sheet.column(0).width = 20
    col_index = 1
    service_envs.each do |service_env|
      @sheet.row(0).push "#{service_env[:service]['name']} #{service_env[:environment]['name']}"
      @sheet.column(col_index).width = 15
      col_index += 1
    end
  end
  
  def create_machine_row(machine, service_cells)
    default_format = Spreadsheet::Format.new color: :black, size: 12
    row = @sheet.row(@row_index)
    row.default_format = default_format
    row.push machine['ip_address']
    row.set_format(0, @machine_label_format)
    col = 1
    service_cells.each do |service_cell|
      row.column(col).outline_level = 1
      if (service_cell[:match])
        row.push "XXXXXXX"
        row.set_format(col, @has_service_format)
      else
        row.push ""
        row.set_format(col, @no_service_format)
      end
      col += 1
    end
    
    @row_index += 1
  end
  

end