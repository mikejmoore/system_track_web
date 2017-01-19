require 'object_view'
require_relative '../page_utils'



class MachineNicEntry < ObjectView::Div
  include ObjectView
  

  def initialize(session, machine, nic_hash = nil)
    super()
    
    form = self.add Form.new
    form.css_class = "col s12"
    form.id = "machine_nic_form"
    form.style = {margin_bottom: "0px", padding_bottom: "0px", border: "1px solid gray"}

    row = form.add Div.new
    row.css_class = "row"
    
    id_hidden = form.add HiddenInput.new()
    id_hidden.name = "machine_id"
    id_hidden.value = machine['id']
    
    if (nic_hash)
      id_hidden = form.add HiddenInput.new()
      id_hidden.name = "id"
      id_hidden.value = nic_hash['id']
    end

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "ip_address"
    edit.name = edit.id
    edit.value = nic_hash['ip_address'] if (nic_hash)
    edit.css_class = "validate"
    label = input_holder.add Label.new "IP Address"
    label.for = edit.name

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "mac_address"
    edit.name = edit.id
    edit.value = nic_hash['mac_address']  if (nic_hash)
    edit.css_class = "validate"
    label = input_holder.add Label.new "MAC"
    label.for = edit.name

    row = form.add Div.new
    row.css_class = "row"

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "interface"
    edit.name = "interface"
    edit.value = nic_hash['interface']  if (nic_hash)
    edit.css_class = "validate"
    label = input_holder.add Label.new "Interface"
    label.for = edit.name
    
    input_holder = row.add Div.new
    input_holder.id = "ssh_checkbox_holder"
    input_holder.css_class = "input-field col s6"
    check = input_holder.add Checkbox.new
    check.id = "ssh"
    check.name = "ssh"
    check.attr('checked', 'checked') if (nic_hash) && (nic_hash['ssh_service'])
    label = input_holder.add Label.new "SSH"
    label.attr('for', check.id)
    

    row = form.add Div.new
    row.css_class = "row"
    nic_hash_id = ""
    nic_hash_id = nic_hash['id'] if (nic_hash)
    save_button = row.add Link.new(nil, "Save")
    save_button.id = "save"
    save_button.css_class = "btn-flat btn-tiny col s3"
    save_button.on_click = "saveMachineNetworkCard(#{nic_hash_id});"

    cancel_button = row.add Link.new(nil, "Cancel")
    cancel_button.id = "cancel"
    cancel_button.css_class = "btn-flat btn-tiny col s3"
    cancel_button.on_click = "cancelNetworkCardEdit(#{nic_hash_id});"
    
  end
  
end