require_relative "../../views/object_view/service/service_list_table"
require_relative "../../views/object_view/service/service_entry_form"
require_relative "../../views/object_view/service/service_summary_page"

class V1::ServicesController < ApplicationController
  before_action :validate_credentials
  #before_filter :verify_csrf, only: [:create]
  
  def summary
    page = ServiceSummaryPage.new(session)
    render text: page.render()
  end
  
  def save
    service = params
    # machine_param_keys = params.keys.select{ |key|  key.start_with? "machine_"}
    # service['machine_services'] = []
    # machine_param_keys.each do |key|
    #   machine_id = key["machine_".length..key.length].to_i
    #   service['machine_services'] << {machine_id: machine_id}
    # end

    env_param_keys = params.keys.select{ |key|  key.start_with? "environment_"}
    


    service = MachinesProxy.new.save_service(session, service)
    render text: service.to_json
  end
  
  def table_ajax
    table = ServiceListTable.new(session, @current_user.account_id)
    render text: table.render
  end
  
  def edit_form_ajax
    service_id = params[:service_id].to_i
    form = ServiceEntryForm.new(session, service_id)
    render text: form.render
  end
  
end