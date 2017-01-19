require_relative "../base_page"
require_relative "../../../../lib/view/service_location_utils"

class ServicesLocationsTableBase
  include SystemTrack
  include ServiceLocationsUtils
  
  def initialize(network, services)
    super()
    if (network['machines'].length > 0)
      service_hash = find_service_environments_hash(network, services)
      raise "Could not find service environments" if (!service_hash)
      
      ordered_service_env_list = []
      service_hash.keys.sort.each do |key|
        column_service_env = service_hash[key]
        ordered_service_env_list << column_service_env
      end

      make_header_row(ordered_service_env_list)
      
      network['machines'].each do |machine|
        service_cells = []
        ordered_service_env_list.each do |column_service_env|
          column_environment = column_service_env[:environment]
          column_service = column_service_env[:service]
          machine_services = column_service['machine_services']
          match = machine_services.find {|s| 
            (s['machine_id'] == machine['id']) && (s['environment_id'] == column_environment['id'])
          }
          service_cells << {service: column_service, match: match}
        end
        create_machine_row(machine, service_cells)
      end
    end
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
  
  
  
end
