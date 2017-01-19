require_relative '../web_spec_helper'


feature "Can view graphical layout of machines", js: true do

  scenario "Machines appear in correct network", js: true do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    login user.email, user_hash[:password]

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
      end
    end
    click_on "Layout"
    network_hashes.each do |network|
      within("#network_#{network['id']}") do
        network[:machines].each do |machine|
          within("#machine_#{machine['id']}") do
            expect(page).to have_content machine['name']
          end
        end
      end
    end
  end
  
  
  
  
end