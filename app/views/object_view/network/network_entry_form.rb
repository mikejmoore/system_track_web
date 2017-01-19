require 'object_view'
require_relative '../page_utils'

class NetworkEntryForm < ObjectView::Div 
  include ObjectView
  include SystemTrack
  

  def initialize(session, network_id = nil)
    super()
    
    network = nil
    
    self.id = "network_form_holder"
    self.style = {background: "#ffffff", border_radius: "5px", width: "90%", margin_bottom: "20px", margin_top: "20px"}
    
    form = self.add Form.new
    form.css_class = "col s12"
    form.id = "network_form"
    form.style = {width: "100%", margin_bottom: "0px", padding_bottom: "0px"}
    form.action = "/networks/save"

    if (network_id) && (network_id > 0)
      id_hidden = form.add HiddenInput.new
      id_hidden.name = "id"
      id_hidden.value = network_id.to_s
      network = MachinesProxy.new.network(session, network_id)
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
    edit.value = network['name'] if (network)
    label = input_holder.add Label.new "Name"
    label.for = "name"

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "code"
    edit.name = "code"
    edit.css_class = "validate"
    edit.value = network['code'] if (network)
    label = input_holder.add Label.new "Code"
    label.for = "code"

    
    row = form.add Div.new
    row.css_class = "row"

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "address"
    edit.name = "address"
    edit.value = network['address'] if (network)
    edit.css_class = "validate"
    label = input_holder.add Label.new "Address"
    label.for = "address"


    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "mask"
    edit.name = "mask"
    edit.value = network['mask'] if (network)
    edit.css_class = "validate"
    label = input_holder.add Label.new "Mask"
    label.for = "mask"


    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add Combobox.new

    status_list = MachinesProxy.new.network_status_list
    status_list.each do |status|
      option = edit.option(status['name'], status['code'])
      if (network) && (status['code'] == network['status'])
        option.attr('selected', 'selected')
      end
      
    end
    edit.id = "status"
    edit.name = "status"
    edit.css_class = "validate"
    label = input_holder.add Label.new "Status"
    label.for = "status"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "price"
    edit.name = "price"
    edit.css_class = "validate"
    edit.value = network['price'].to_s if (network)
    label = input_holder.add Label.new "Price"
    label.for = "price"
    
    row.style = {margin_bottom: "0px"}
    
    row = self.add Div.new
    row.css_class = "row"
    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    submit_button = button_holder.add Button.new("Submit")
    submit_button.id = "submit"
    submit_button.css_class = "waves-effect waves-light btn"
    submit_button.on_click = "submitNetworkCreateForm();"

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
        
        // Prevent labels from overlapping field values
        Materialize.updateTextFields();
    });
    "
  end
  
end