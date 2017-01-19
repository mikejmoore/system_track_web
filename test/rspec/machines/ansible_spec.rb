require_relative '../api_spec_helper'

include ApiHelper
include SystemTrack




describe "Provides ansible dynamic inventory from account machines" do

  it "Returns valid json format" do
    account_id = 1
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    
    pub_key = File.read(ENV['HOME'] + "/.ssh/id_rsa.pub")

    user_service = UsersProxy.new
    ssh_key = user_service.add_ssh_key(session, user.id, pub_key, "My SSH")
    
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

    public_key_hash = ssh_key['public_key_hash']    
    params = {:operation => "list", :hash => public_key_hash}
    response = get "/v1/ansible_hosts", {operation: 'list', public_key_hash: public_key_hash}
    expect(response.status).to eq 200
    
    cipher_info = JSON.parse(response.body)
    hosts_data = CryptUtils.decrypt_ansible_host_response(cipher_info)
    puts hosts_data
  end
  
  
end