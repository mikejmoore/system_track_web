require 'object_view'
require_relative '../page_utils'
require_relative './machine_nic_entry'



class MachineEntryForm < ObjectView::Div 
  include ObjectView
  include SystemTrack
  

  def initialize(session, machine = nil, mode = :view)
    super()
    self.id = "machine_form_holder"
    self.style = {background: "#ffffff", border_radius: "5px", width: "90%", margin_bottom: "20px", margin_top: "20px"}
    
    form = self.add Form.new
    form.css_class = "col s12"
    form.id = "machine_form"
    form.style = {width: "100%", margin_bottom: "0px", padding_bottom: "0px"}
    form.action = "/v1/machines/save"

    if (machine) && (machine['id'])
      id_hidden = form.add HiddenInput.new
      id_hidden.name = "id"
      id_hidden.value = machine['id']
      machine = MachinesProxy.new.machine(session, machine['id'])
    end
    
    form.add PageUtils.authenticity_token_hidden(session)

    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"

    edit = nil
    if (mode == :view)
      edit = read_only_text_field("Name", "name", input_holder, machine['name'])
    else
      edit = input_holder.add TextInput.new
      edit.type = "text"
      edit.id = "name"
      edit.name = edit.id
      edit.value = machine['name'] if (machine)
      edit.css_class = "validate"
      label = input_holder.add Label.new "Name"
      label.for = edit.id
    end

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    if (mode == :view)
      edit = read_only_text_field("Code", "code", input_holder, machine['code'])
    else
      edit = input_holder.add TextInput.new
      edit.type = "text"
      edit.id = "code"
      edit.name = edit.id
      edit.value = machine['code'] if (machine)
      if (mode == :view)
        edit.attr('readonly', true) 
        edit.style = {border_bottom: 'none'}
      end
    
      edit.css_class = "validate"
      label = input_holder.add Label.new "Code"
      label.for = edit.name
    end
    
    row = form.add Div.new
    row.css_class = "row"

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    if (mode == :view)
      edit = read_only_text_field("Primary IP Address", "ip_address", input_holder, machine['ip_address'])
    else
      edit = input_holder.add TextInput.new
      edit.type = "text"
      edit.id = "ip_address"
      edit.name = "ip_address"
      edit.value = machine['ip_address']  if (machine)
      if (mode == :view)
        edit.attr('readonly', true) 
        edit.style = {border_bottom: 'none'}
      end
      edit.css_class = "validate"
      label = input_holder.add Label.new "Primary IP Address"
      label.for = "ip_address"
    end

    row = form.add Div.new
    row.css_class = "row"
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    if (mode == :view)
      edit = read_only_text_field("Status", "status", input_holder, MachineLogic::STATUS[machine['status'].to_sym])
    else
      edit = input_holder.add Combobox.new
      MachineLogic::STATUS.keys.each do |code|
        name = MachineLogic::STATUS[code]
        option = edit.option(name, code)
        if (machine) && (code == machine['status'])
          options.attr('selected', 'selected')
        end
      end
      edit.id = "status"
      edit.name = "status"
      edit.css_class = "validate"
      if (mode == :view)
        edit.attr('readonly', true) 
        edit.style = {border_bottom: 'none'}
      end
      label = input_holder.add Label.new "Status"
      label.for = "status"
    end

   
   input_holder = row.add Div.new
   input_holder.css_class = "input-field col s6"
   if (mode == :view)
     edit = read_only_text_field("Price", "price", input_holder, machine['price'])
   else
     edit = input_holder.add TextInput.new
     edit.type = "text"
     edit.id = "price"
     edit.name = edit.id
     edit.value = machine['price']  if (machine)
     if (mode == :view)
       edit.attr('readonly', true) 
       edit.style = {border_bottom: 'none'}
     end
     edit.css_class = "validate"
     label = input_holder.add Label.new "Primary IP Address"
     label.for = "price"
   end
   
   
   #  row = general_content.add Div.new
   #  row.css_class = "row"
   #  tag_holder = row.add Div.new
   #  tag_holder.css_class = "col s6"
   #
   #  tags = tag_holder.add Div.new
   #  tags.css_class = "chips chips-initial"
   #
   #  self.add Javascript.new "
   #    initializeMachineTags();
   #   "
   #
   #  ###### Specs Tab:
   #  row = specs_content.add Div.new
   #  row.css_class = "row"
   #
   #  input_holder = row.add Div.new
   #  input_holder.css_class = "input-field col s3"
   #  edit = input_holder.add TextInput.new
   #  edit.type = "text"
   #  edit.id = "cpu_speed"
   #  edit.name = edit.id
   #  edit.css_class = "validate"
   #  edit.value = machine['cpu_speed']
   #  label = input_holder.add Label.new "CPU Speed"
   #  label.for = edit.name
   #
   #  input_holder = row.add Div.new
   #  input_holder.css_class = "input-field col s3"
   #  edit = input_holder.add TextInput.new
   #  edit.type = "text"
   #  edit.id = "cpu_count"
   #  edit.name = edit.id
   #  edit.css_class = "validate"
   #  edit.value = machine['cpu_count']
   #  label = input_holder.add Label.new "CPU Count"
   #  label.for = edit.name
   #
   #
   #  input_holder = row.add Div.new
   #  input_holder.css_class = "input-field col s3"
   #  edit = input_holder.add TextInput.new
   #  edit.type = "text"
   #  edit.id = "memory"
   #  edit.name = edit.id
   #  edit.css_class = "validate"
   #  edit.value = machine['memory']
   #  label = input_holder.add Label.new "Memory"
   #  label.for = edit.name
   #
   #
   #
   #  ###### Interfaces Tab:
   #
   #  row = interface_content.add Div.new
   #  row.css_class = "row"
   #
   #  network_cards = machine['network_cards'] if (machine)
   #  network_cards = [] if (!network_cards)
   #  while (network_cards.length < 4) do
   #     network_cards << {}
   #  end
   #
   #  card_index = 0
   #  network_cards.each do |network_card|
   #    row.add MachineNicEntry.new(session, card_index, network_card)
   #    card_index += 1
   #  end
     
    row.style = {margin_bottom: "0px"}
    
    row = row.add Div.new
    row.id = "machine_buttons"
    row.css_class = "row"
    if (mode == :view)
      button_holder = row.add Div.new
      button_holder.css_class = "col s3"
      submit_button = button_holder.add Link.new(nil, "Edit")
#      submit_button = button_holder.add Div.new("Edit")
      submit_button.id = "edit"
      submit_button.css_class = "waves-effect waves-light btn"
      submit_button.on_click = "window.location = '/v1/machines/edit_machine?machine_id=#{machine['id']}';"

      # button_holder = row.add Div.new
      # button_holder.css_class = "col s3"
      # cancel_button = button_holder.add Button.new("Exit")
      # cancel_button.id = "exit"
      # cancel_button.css_class = "waves-effect waves-light btn"
      # cancel_button.style = {padding_left: "10px", padding_bottom: "10px"}
      # cancel_button.on_click = "cancelMachineEntry();"
    elsif (mode == :edit)
      if (machine == nil)
        button_holder = row.add Div.new
        button_holder.css_class = "col s3"
        submit_button = button_holder.add Button.new("Submit")
        submit_button.id = "submit"
        submit_button.attr('name', "submit")
        submit_button.css_class = "waves-effect waves-light btn"

        button_holder = row.add Div.new
        button_holder.css_class = "col s3"
        cancel_button = button_holder.add Button.new("Cancel")
        cancel_button.attr('name', "cancel")
        cancel_button.id = "cancel"
        cancel_button.css_class = "waves-effect waves-light btn"
        cancel_button.style = {padding_left: "10px", padding_bottom: "10px"}
      else
        button_holder = row.add Div.new
        button_holder.css_class = "col s3"
        submit_button = button_holder.add Button.new("Submit")
        submit_button.id = "submit"
        submit_button.css_class = "waves-effect waves-light btn"
        #submit_button.on_click = "submitMachineCreateForm();"

        button_holder = row.add Div.new
        button_holder.css_class = "col s3"
        cancel_button = button_holder.add Button.new("Cancel")
        cancel_button.id = "cancel"
        cancel_button.css_class = "waves-effect waves-light btn"
        cancel_button.style = {padding_left: "10px", padding_bottom: "10px"}
        #cancel_button.on_click = "cancelMachineEntry();"
      end
    else
      raise "Do not know how to handle mode = '#{mode}'"
    end

    row = form.add Div.new
    #row.style = {height: "10px"}
    row.css_class = "row"
    
    if (mode == :edit)
      self.add Javascript.new "
      $(document).ready(function() {
          $('#status').material_select();
          Materialize.updateTextFields();
      });
    
      "
    end
  end
  
  
  
  def read_only_text_field(label, element_id, parent, value)
    label_element = parent.add Div.new label
    label_element.style = {font_size: "0.75rem", color: "#9e9e9e"}
    edit = parent.add Span.new value
    edit.attr('readonly', true) 
    edit.style = {border_bottom: 'none'}
    edit.id = element_id
    return edit
  end
  
  
end