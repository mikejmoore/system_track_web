require_relative '../web_spec_helper'


feature "Can view reports", js: true do

  scenario "Can view service on machines", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    login user.email, user_hash[:password]

    services = []
    (1..3).each do
      service = service_hash(user.account_id)
      services << MachinesProxy.new.save_service(session, service)
    end

    network_hashes = []
    (1..2).each do
      network = MachinesProxy.new.save_network(session, network_hash(user.account_id))
      network[:machines] = []
      network_hashes << network
      (1..3).each do 
        machine = machine_hash(user.account_id)
        machine[:network_id] = network['id']
        machine = MachinesProxy.new.save_machine(session, machine)
        network[:machines] << machine
        
        MachinesProxy.new.attach_service_to_machine(session, services.first['id'], machine['id'], machine['ip_address'], "prod")
        MachinesProxy.new.attach_service_to_machine(session, services.last['id'], machine['id'], machine['ip_address'], "test")
      end
    end
    click_on "Reports"
    click_on "Services Locations"
    expect(page).to have_content(services.first['name'])
    expect(page).to have_content(services.last['name'])
  end
  
  
  
  
end