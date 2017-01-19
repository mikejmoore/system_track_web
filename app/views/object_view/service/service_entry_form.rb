require 'object_view'
require_relative '../page_utils'


class ServiceEntryForm < ObjectView::Div 
  include ObjectView
  include SystemTrack

  def initialize(session, service_id = nil)
    super()
    @session = session
    @service = nil
    
    self.id = "service_form_holder"
    self.style = {background: "#ffffff", border_radius: "5px", width: "90%", margin_bottom: "20px", margin_top: "20px"}
    
    form = self.add Form.new
    form.css_class = "col s12"
    form.id = "service_form"
    form.style = {width: "100%", margin_bottom: "0px", padding_bottom: "0px"}
    form.action = "/services/save"

    if (service_id) && (service_id > 0)
      id_hidden = form.add HiddenInput.new
      id_hidden.name = "id"
      id_hidden.value = service_id.to_s
      @service = MachinesProxy.new.service(session, service_id)
    end

    form.add PageUtils.authenticity_token_hidden(session)

    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "name"
    edit.name = "name"
    edit.css_class = "validate"
    edit.value = @service['name'] if (@service)
    label = input_holder.add Label.new "Name"
    label.for = "name"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "code"
    edit.name = "code"
    edit.css_class = "validate"
    edit.value = @service['code'] if (@service)
    label = input_holder.add Label.new "Code"
    label.for = edit.name
    
    row = form.add Div.new
    row.css_class = "row"
#    row.style = {margin_bottom: "0px"}

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextArea.new
    edit.id = "description"
#    edit.name = "description"
    edit.value = @service["description"] if (@service)
    edit.css_class = "materialize-textarea"
    label = input_holder.add Label.new "Description"
    label.for = "description"
    
    # row = form.add Div.new
    # row.css_class = "row"
    # row.add machine_selector
    # row = form.add Div.new
    # row.css_class = "row"
    # row.add environment_selector
    
    row = self.add Div.new
    row.css_class = "row"
    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    submit_button = button_holder.add Button.new("Submit")
    submit_button.id = "submit"
    submit_button.css_class = "waves-effect waves-light btn"
    submit_button.on_click = "submitServiceCreateForm();"

    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    cancel_button = button_holder.add Button.new("Cancel")
    cancel_button.id = "cancel"
    cancel_button.on_click = "cancelNetworkEntry();"
    cancel_button.css_class = "waves-effect waves-light btn"
    cancel_button.style = {padding_left: "10px", padding_bottom: "10px"}

    row = form.add Div.new
    #row.style = {height: "10px"}
    row.css_class = "row"
    
    self.add Javascript.new "
    $(document).ready(function() {
        $('#status').material_select();
        Materialize.updateTextFields();
    });
    "
  end
  
  #
  # def service_has_machine?(machine_id)
  #   if (@service)
  #     @service['machine_services'].each do |machine_service|
  #       return true if (machine_service['machine_id'] == machine_id)
  #     end
  #   end
  #   return false
  # end
  #
  # def service_has_environment?(environment_id)
  #   if (@service)
  #     @service['environments'].each do |environment|
  #       return true if (environment['id'] == environment_id)
  #     end
  #   end
  #   return false
  # end

  # def environment_selector
  #   holder_div = Div.new
  #   environments = MachinesProxy.new.environment_list(@session)
  #   environments.each do |environment|
  #     env_div = holder_div.add Div.new
  #     env_div.css_class = "row"
  #     env_div.id = "row_env_#{environment['id']}"
  #     div = env_div.add Div.new
  #     div.id = "env_checkbox_holder_#{environment['id']}"
  #     div.css_class = "col s1"
  #     check = div.add Checkbox.new
  #     check.id = "environment_#{environment['id']}"
  #     check.name = "environment_#{environment['id']}"
  #     check.attr('checked', 'checked') if service_has_environment?(environment['id'])
  #     label = div.add Label.new "&nbsp;"
  #     label.attr('for', check.id)
  #
  #     div = env_div.add Div.new environment['name']
  #     div.css_class = "col s5"
  #
  #   end
  #   return holder_div
  # end
  
  
  # def machine_selector
  #   network_list = MachinesProxy.new.network_list(@session)
  #   network_list.sort! { |a, b|
  #     a['address'] <=> b['address']
  #   }
  #   network_machines = {}
  #   machine_found_without_network = false
  #   machines = MachinesProxy.new.machine_list(@session)
  #   machines.each do |machine|
  #     network_id = machine['network_id']
  #     if (!network_id)
  #       network_id = "None"
  #       machine_found_without_network = true
  #     end
  #     network_machines[network_id] = [] if (network_machines[network_id] == nil)
  #     network_machines[network_id] << machine
  #   end
  #
  #   if (machine_found_without_network)
  #     network_list << {'id' => "None", 'address' => "No Network"}
  #   end
  #
  #   holder = Ul.new
  #   holder.css_class = "collapsible"
  #   network_list.each do |network|
  #     li = holder.add Li.new
  #     header = li.add Div.new network['address']
  #     header.id = "network_header_#{network['id']}"
  #     header.css_class = 'collapsible-header'
  #
  #     body = li.add Div.new
  #     body.css_class = "collapsible-body"
  #
  #     machines = network_machines[network['id']]
  #     if (machines)
  #       machines.each do |machine|
  #         machine_div = body.add Div.new
  #         machine_div.css_class = "row"
  #         machine_div.id = "row_machine_#{machine['id']}"
  #         div = machine_div.add Div.new
  #         div.id = "machine_checkbox_holder_#{machine['id']}"
  #         div.css_class = "col s1"
  #         # <input type="checkbox" id="test5" />
  #         #       <label for="test5">Red</label>
  #         check = div.add Checkbox.new
  #         check.id = "machine_#{machine['id']}"
  #         check.name = "machine_#{machine['id']}"
  #         check.attr('checked', 'checked') if service_has_machine?(machine['id'])
  #         label = div.add Label.new "&nbsp;"
  #         label.attr('for', check.id)
  #
  #         div = machine_div.add Div.new machine['code']
  #         div.css_class = "col s5"
  #
  #         div = machine_div.add Div.new machine['ip_address']
  #         div.css_class = "col s6"
  #       end
  #     end
  #   end
  #   self.add Javascript.new "
  #   $(document).ready(function(){
  #       $('.collapsible').collapsible({
  #         accordion : false // A setting that changes the collapsible behavior to expandable instead of the default accordion style
  #       });
  #     });
  #   "
  #
  #   return holder
  # end
  #
end