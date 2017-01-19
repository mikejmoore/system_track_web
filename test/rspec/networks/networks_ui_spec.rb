require_relative '../web_spec_helper'
require_relative '../../../app/views/object_view/network/network_entry_form'
include SystemTrack

feature "Can maintain networks", js: true do

  scenario "Can view networks list", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    network_hashes = []
    (1..2).each do
      network_hashes << network_hash(user.account_id)
      network = MachinesProxy.new.save_network(session, network_hashes.last)
      (1..3).each do 
        machine = machine_hash(user.account_id)
        machine[:network_id] = network['id']
        MachinesProxy.new.save_machine(session, machine)
      end
    end
    
    login user.email, user_hash[:password]
    within "#side_menu" do
      click_on "Network"
    end
    network_hashes.each do |network|
      expect(page).to have_content(network[:name])
    end
  end

  scenario "Can add a new network" do 
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    new_network = network_hash(user.account_id)
    login user.email, user_hash[:password]
    within "#side_menu" do
      click_on "Network"
    end
    click_on "add_network_button"    
    
    within "#network_form" do
      fill_in "name", with: new_network[:name]
      fill_in "code", with: new_network[:code]
      fill_in "address", with: new_network[:address]
      fill_in "mask", with: new_network[:mask]
      fill_in "price", with: new_network[:price]
      
      # Trickery to use Materialize CSS combobox.  Matrialize CSS replaces combo with UL/LI clickable items
      find("input.select-dropdown").click
      find("li", text: "Installed").click
      
    end
    click_on "submit"
    stored_networks = MachinesProxy.new.network_list(session, user.account_id)
    
    within "#network_table_wrapper" do
      expect(page).to have_content(new_network[:name])
    end
  end
  
  scenario "Can edit a network", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    network = network_hash(user.account_id)
    MachinesProxy.new.save_network(session, network)
    
    login user.email, user_hash[:password]
    within "#side_menu" do
      click_on "Network"
    end
    
    within "#network_table_wrapper" do
      expect(page).to have_content(network[:name])
      sleep 2
      click_on "Edit"
    end
    
    within "#network_edit_form_holder" do 
      fill_in "name", with: "My Network"
      fill_in "code", with: "my.net"
      fill_in "price", with: "100.50"
      click_on "Submit"
    end

    within "#network_table_wrapper" do
      expect(page).to have_content("My Network")
    end
  end
  
  scenario "Can cancel out of adding new machine" do 
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    login user.email, user_hash[:password]

    new_network = network_hash(user.account_id)
    within "#side_menu" do
      click_on "Network"
    end

    click_on "Add Network"
    within "#network_edit_form_holder" do 
      fill_in "name", with: new_network[:name]
      fill_in "code", with: new_network[:code]
      click_on "Cancel"
    end
    expect(page).to_not have_content("Submit")
  end
  
  
end