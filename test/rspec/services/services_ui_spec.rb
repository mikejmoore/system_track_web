require_relative '../web_spec_helper'
require "system_track_shared"
require_relative "../../../app/views/object_view/service/service_summary_page"
include SystemTrack

feature "Can maintain services", js: true do

  scenario "Can view services list", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    service_hashes = []
    (1..2).each do
      service_hashes << service_hash(user.account_id)
      MachinesProxy.new.save_service(session, service_hashes.last)
    end
    
    login user.email, user_hash[:password]
    
    within "#side_menu" do
      click_on "Service"
    end
    service_hashes.each do |service|
      expect(page).to have_content(service[:name])
    end
  end

  scenario "Can assign service to a network", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    service_hashes = []
    service = service_hash(user.account_id)
    service = MachinesProxy.new.save_service(session, service)

    network = network_hash(user.account_id)
    network = MachinesProxy.new.save_network(session, network)

    service = MachinesProxy.new.attach_service_to_network(session, service['id'], network['id'])
    expect(service['networks'].length).to eq 1
    expect(service['networks'].first['code']).to eq network['code']
  end
  
  scenario "Can assign service to a machine in network", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    account_id = user['account_id']
    
    prod_environment = MachinesProxy.new.save_environment(session, environment_hash(account_id))
    
    service_hashes = []
    service = service_hash(user.account_id)
    service = MachinesProxy.new.save_service(session, service)

    network = network_hash(user.account_id)
    network = MachinesProxy.new.save_network(session, network)
    
    machine = machine_hash(user.account_id)
    machine[:network_id] = network['id']
    machine = MachinesProxy.new.save_machine(session, machine)
    
    

    service = MachinesProxy.new.attach_service_to_network(session, service['id'], network['id'])
    MachinesProxy.new.attach_environment_to_network(session, prod_environment['id'], network['id'])
    card_ip_address = "10.10.3.4"
    service = MachinesProxy.new.attach_service_to_machine(session, service['id'], machine['id'], card_ip_address, prod_environment['id'])
    
    expect(service['machine_services'].length).to eq 1
    expect(service['machine_services'].first['machine_id']).to eq machine['id']
    expect(service['networks'].length).to eq 1
    expect(service['networks'].first['code']).to eq network['code']
  end
  

  scenario "Can add a new service" do 
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    networks = []
    # Add some networks and machines
    (1..4).each do
      network = MachinesProxy.new.save_network(session, network_hash(user.account_id))
      networks << network
      network['machines'] = []
      (1..4).each do 
        machine_in = machine_hash(user.account_id)
        machine_in[:network_id] = network['id']
        machine = MachinesProxy.new.save_machine(session, machine_in)
        network['machines'] << machine
      end
    end
    selected_machine = nil
    new_service = service_hash(user.account_id)
    login user.email, user_hash[:password]
    within "#side_menu" do
      click_on "Service"
    end
    click_on "add_service_button"    
    
    within "#service_form" do
      fill_in "name", with: new_service[:name]
      fill_in "code", with: new_service[:code]
      fill_in "description", with: new_service[:description]
      selected_network = networks.first
      
      network_header = find "#network_header_#{selected_network['id']}"
      network_header.click
      selected_machine = networks.first['machines'].first

      # Trickery to click materialcss check box.  Capybara can't find checkbox, but clicking the holding div checks the box.
      find("#machine_checkbox_holder_#{selected_machine['id']}").click
    end
    click_on "submit"
    
    # New service should now appear in service table.
    within "#service_table_wrapper" do
      expect(page).to have_content new_service[:name]
    end
    
    stored_services = MachinesProxy.new.service_list(session, user.account_id)
    saved_service = stored_services.first
    expect(saved_service['machine_services'].length).to eq 1
    expect(saved_service['machine_services'].first['machine_id']).to eq selected_machine['id']
    within "#service_table_wrapper" do
      expect(page).to have_content(new_service[:name])
    end
  end
  
  scenario "Can edit a service", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    service = service_hash(user.account_id)
    MachinesProxy.new.save_service(session, service)
    
    login user.email, user_hash[:password]
    within "#side_menu" do
      click_on "Service"
    end
    
    within "#service_table_wrapper" do
      expect(page).to have_content(service[:name])
      within ("#service_table") do
        expect(page).to have_content(service['name'])
      end
    end
    
    sleep 2
    find("#service_table").click_on "Edit"
    
    within "#service_edit_form_holder" do 
      fill_in "name", with: "My Service"
      fill_in "code", with: "special.service"
      click_on "Submit"
    end

    within "#service_table_wrapper" do
      expect(page).to have_content("My Service")
    end
  end
  
  scenario "Can cancel out of adding new machine" do 
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    login user.email, user_hash[:password]

    new_service = service_hash(user.account_id)
    click_on "Service"
    click_on "Add Service"
    within "#service_edit_form_holder" do 
      fill_in "name", with: new_service[:name]
      fill_in "code", with: new_service[:code]
      click_on "Cancel"
    end
    expect(page).to_not have_content("Submit")
  end
  
  
end