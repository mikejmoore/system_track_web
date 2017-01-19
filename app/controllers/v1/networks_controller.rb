require_relative "../../views/object_view/network/network_list_table"
require_relative "../../views/object_view/network/network_entry_form"
require_relative "../../views/object_view/network/network_summary_page"

class V1::NetworksController < ApplicationController
  before_action :validate_credentials
  #before_filter :verify_csrf, only: [:create]
  
  
  def summary
    page = NetworkSummaryPage.new(session)
    render text: page.render()
  end
  
  def save
    machine = params
    machine = MachinesProxy.new.save_network(session, machine)
    render text: machine.to_json
  end
  
  def table_ajax
    table = NetworkListTable.new(session, @current_user.account_id)
    render text: table.render
  end
  
  def edit_form_ajax
    network_id = params[:network_id].to_i
    form = NetworkEntryForm.new(session, network_id)
    render text: form.render
  end
  
end