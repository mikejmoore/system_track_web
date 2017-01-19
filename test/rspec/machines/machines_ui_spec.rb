require_relative '../web_spec_helper'


feature "Can maintain machines", js: true do

  scenario "Can view machine list", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    machine_hashes = []
    (1..2).each do
      machine = machine_hash(user.account_id)
      machine_hashes << machine
      MachinesProxy.new.save_machine(session, machine)
    end
    login user.email, user_hash[:password]
    machine_hashes.each do |machine|
      expect(page).to have_content(machine[:name])
    end

    # (1..1).each do |i|
    #   UsersProxy.new.validate_token(session[:user][:credentials], context = "Unknown Context")
    # end
    # puts "Curl command:\ncurl -H 'Connection: close' -H 'Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3' -H 'Accept: */*' 'http://localhost:3000/api/v1/auth/validate_token?access-token=#{session[:user][:credentials]['access-token']}&uid=#{session[:user][:credentials][:uid]}&client=#{session[:user][:credentials][:client]}'"
    
    visit "/"
    
    (1..2).each do 
      new_machine = machine_hash(user.account_id)

      within "#side_menu" do
        click_on "Machines"
      end

      click_on "Add Machine"
      within "#machine_form_holder" do
        fill_in "name", with: new_machine[:name]
        fill_in "code", with: new_machine[:code]
        fill_in "ip_address", with: new_machine[:ip_address]
        fill_in "price", with: new_machine[:price]

        # Trickery to use Materialize CSS combobox.  Matrialize CSS replaces combo with UL/LI clickable items
        find("input.select-dropdown").click
        find("li", text: "Installed").click
        click_on "Submit"
      end
      expect(page).to have_content(new_machine[:name])
      expect(page).to have_content(new_machine[:code])
      nic = new_machine[:network_cards].first
      click_on "Add Card"
      within("#nic_table") do
        fill_in "ip_address", with: nic[:ip_address]
        fill_in "mac_address", with: nic[:mac_address]
        fill_in "interface", with: nic[:interface]
        click_on "Save"
      end

      within("#nic_table") do
        expect(page).to have_content(nic['ip_address'])
      end
      machine_hashes << new_machine
    end
    
    click_on "Machines"
    machine_hashes.each do |machine|
      expect(page).to have_content(machine[:name])
    end
    
    
  end
  
  
  scenario "Can edit an existing machine" do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    login user.email, user_hash[:password]
    
    machine = machine_hash(user.account_id)
    machine_json = SystemTrack::MachinesProxy.new.save_machine(session, machine)
    visit "/"
    within "#side_menu" do
      click_on "Machines"
    end
    
    sleep 1
    within "#machine_table" do
      click_on "Details"
    end

    
    find("#edit").click
#    click_on "Edit"
    within "#machine_form" do
      expect(page).to have_xpath("//input[@value='#{machine_json["name"]}']")
      expect(page).to have_xpath("//input[@value='#{machine_json["ip_address"]}']")
      expect(page).to have_xpath("//input[@value='#{machine_json["code"]}']")
    end
  end
  
  scenario "Can cancel out of adding new machine" do 
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    machine_hashes = []
    (1..2).each do
      machine = machine_hash(user.account_id)
      machine_hashes << machine
      MachinesProxy.new.save_machine(session, machine)
    end
    login user.email, user_hash[:password]

    new_machine = machine_hash(user.account_id)

    click_on "Add Machine"
    within "#machine_form" do
      fill_in "name", with: new_machine[:name]
      fill_in "code", with: new_machine[:code]
      fill_in "ip_address", with: new_machine[:ip_address]
      fill_in "price", with: new_machine[:price]
      click_on "Cancel"
    end
    expect(page).to_not have_content("Submit")
  end
  
  
end