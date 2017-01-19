require 'object_view'

class MachineGraphicalLayout < ObjectView::Div
  include ObjectView
  
  def initialize(session, account_id)
    super()
    @session = session
    @account_id = account_id
    networks = SystemTrack::MachinesProxy.new.network_list(session, account_id)
    networks.each do |network|
      add_network_layout(network)
    end
  end
  
  def add_network_layout(network)
    network_div = self.add Div.new
    network_div.id = "network_#{network['id']}"
    network_div.css_class = "row"
    network_div.style = {margin: "6px", background: "#ffffff", border: "2px solid #444444", border_radius: "4px", padding_top: "3px"}

    div = network_div.add Div.new
    div.css_class = "col s12"

    div = div.add Div.new "<b>#{network['name']}</b>"
    div.css_class = "row"

    machines_row = div.add Div.new
    machines_row.css_class = "row"
    
    services = SystemTrack::MachinesProxy.new.service_list(@session)
    machines = SystemTrack::MachinesProxy.new.machines_in_network(@session, network['id'], @account_id)
    machines.each do |machine|
      machine_div = machines_row.add Div.new
      machine_div.id = "machine_#{machine['id']}"
      machine_div.css_class = "machine z-depth-1"
      span = machine_div.add Span.new "#{machine['name']}"
      span.style = {margin_top: "3px", font_weight: "bold"}

      primary_ip = machine['ip_address']
      network_cards = machine['network_cards']
      if (!primary_ip)
        network_cards.each do |network_card|
          if (network_card['ssh_service'])
            primary_ip = network_card['ip_address']
          end
        end
      end

      ip_addresses = []
      primary_ip_div = machine_div.add Div.new primary_ip
      primary_ip_div.css_class = "ip-primary"

      network_cards.each do |network_card|
        if (network_card['ip_address'] != primary_ip)
          card_div = machine_div.add Div.new network_card['ip_address']
          card_div.css_class = "ip-secondary"
        end
      end
      
      if (machine['brand'])
        span = machine_div.add Div.new("#{machine['brand']} #{machine['model']}")
        span.style = {width: "100%"}
      end
      
      if (machine['os'])
        parts = machine['os'].split(":")
        os = parts.first
        if (os.length > 0)
          os = os.capitalize
        end
        version = parts.last if (parts.length > 1)
        span = machine_div.add Div.new("#{os} #{version}")
        span.style = {width: "100%"}
      end
      
      machine['machine_services'].each do |machine_service|
        service_id = machine_service['service_id']
        environment = machine_service['environment']
        service = services.find {|s| s['id'] == service_id}
        service_div = machine_div.add Div.new "<span>#{service['name']} #{environment['code'].upcase}</span>"
        service_div.css_class = "service"
      end
    end
  end
  
  
end