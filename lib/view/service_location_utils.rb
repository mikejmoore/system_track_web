module ServiceLocationsUtils

  def find_service_environments_hash(network, services)
    service_hash = {}
    if (network['environments'])
      network['environments'].each do |environment|
        services.each do |service|
          if (service['environments'].find{|e| e['id'] == environment['id']})
            service_hash["#{environment['code']}.#{service['code']}"] = {service: service, environment: environment}
          end
        end
      end
    end
    return service_hash
  end

end