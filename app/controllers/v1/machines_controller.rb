require_relative "../../views/object_view/summary_page"
require_relative "../../views/object_view/machine/machine_list_table"
require_relative "../../views/object_view/machine/machine_entry_form"
require_relative "../../views/object_view/machine/machine_entry_page"
require_relative "../../views/object_view/machine/machine_details_page"
require_relative "../../views/object_view/machine/machine_nic_table"
require_relative "../../views/object_view/machine/machine_graphical_layout"


class V1::MachinesController < ApplicationController
  before_action :validate_credentials, except: [:ansible_hosts]
  skip_before_action :sign_on_if_credentials, only: [:ansible_hosts]
  skip_before_action :authenticate_token, only: [:ansible_hosts]
  skip_before_action :verify_authenticity_token, only: [:ansible_hosts]
  skip_before_action :find_user_from_session, only: [:ansible_hosts]
  include SystemTrack
  
  def summary
    page = SummaryPage.new(session)
    render text: page.render()
  end
  
  
  def toggle_service
    service_on = MachinesProxy.new.toggle_service_for_machine(session, params[:machine_id], params[:service_id], params[:environment_code])
    render text: {service_on: service_on}.to_json
  end
  
  def save
    if (!params[:cancel])
      machine = params
      machine['network_cards'] = []
      params.keys.each do |key|
        if (key.start_with? "ip_address_")
          nic = {}
          nic_index = key["ip_address_".length, key.length].to_i
          nic['ip_address'] = params["ip_address_#{nic_index}"]
          nic['mac_address'] = params["mac_address_#{nic_index}"]
          nic['interface'] = params["nic_interface_#{nic_index}"]
          nic['ssh_service'] = (params["nic_ssh_#{nic_index}"] == "on")
          machine['network_cards'] << nic
        end
      end
      machine = MachinesProxy.new.save_machine(session, machine)
      page = MachineDetailsPage.new(session, machine['id'])
      render text: page.render
    else
      page = SummaryPage.new(session)
      render text: page.render()
    end
  end
  
  def show
    machine_id = params[:machine_id].to_i
    page = MachineDetailsPage.new(session, machine_id)
    render text: page.render
  end
  
  def table_ajax
    table = MachineListTable.new(session, @current_user.account_id)
    render text: table.render
  end
  
  def edit_machine
    machine = nil
    if (params[:machine_id])
      machine = MachinesProxy.new.machine(session, params[:machine_id].to_i)
    end
    page = MachineEntryPage.new(session, machine)
    render text: page.render
  end
  
  def edit_form_ajax
    machine_id = params[:machine_id]
    machine = nil
    if (machine_id) && (!machine_id.empty?)
      machine = MachinesProxy.new.machine(session, machine_id.to_i)
    end
    form = MachineEntryForm.new(session, machine, :edit)
    render text: form.render
  end

  def save_network_card
    nic = params
    
    if params[:ssh] == "on"
      nic['ssh_service'] = true
    else
      nic['ssh_service'] = false
    end
    machine_id = nic['machine_id']
    machine = MachinesProxy.new.save_machine_network_card(session, machine_id, nic)
    nic_table = MachineNicTable.new(session, machine)
    render text: nic_table.render
  end
  
  def delete_network_card
    nic_id = params[:network_card_id].to_i
    machine_id = params[:machine_id].to_i
    machine = MachinesProxy.new.delete_machine_network_card(session, nic_id)
    
    nic_table = MachineNicTable.new(session, machine)
    render text: nic_table.render
  end
  
  
  def nic_edit_form_ajax
    machine_id = params[:machine_id]
    machine = MachinesProxy.new.machine(session, machine_id.to_i)
    
    machine_nic_id = params[:machine_nic_id]
    nic = nil
    if (machine_nic_id)
      nic = machine['network_cards'].find {|n|
        n['id'] == machine_nic_id.to_i
      }
    end
    form = MachineNicEntry.new(session, machine, nic)
    render text: form.render
  end


  def view_form_ajax
    machine_id = params[:machine_id].to_i
    machine = MachinesProxy.new.machine(session, machine_id.to_i)
    form = MachineEntryForm.new(session, machine, :view)
    render text: form.render
  end

  
  def ansible_hosts
    public_key_hash = params[:public_key_hash]
    encrypted_hosts_file = MachinesProxy.new.ansible_hosts(public_key_hash)
    send_data encrypted_hosts_file
  end
  
  def graphical_layout
    account_id = @current_user.account_id
    page = BasePage.new(session)
    page.head.add('<link data-turbolinks-track="true" href="/stylesheets/machine_layout.css?body=1" media="screen,projection" rel="stylesheet" />')
    page.right_content.add MachineGraphicalLayout.new(session, account_id)
    render text: page.render
  end
  
end