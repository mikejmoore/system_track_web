require "object_view"

class MachineNicTable < ObjectView::Div
  include ObjectView

  def initialize(session, machine)
    super()
    self.css_class = "col s12"
    self.id = "nic_table"
    
    existing_nics_holder = self.add Div.new
    existing_nics_holder.css_class = "row"
    machine['network_cards'].sort! {|a, b|
      a['ip_address'] <=> b['ip_address']
    }
    machine['network_cards'].each do |nic|
      row = existing_nics_holder.add Div.new
      row.css_class = "row"
      row.id = "nic_row_#{nic['id']}"
      
      div = row.add Div.new nic['ip_address']
      div.css_class = "col s4"

      div = row.add Div.new nic['interface']
      div.css_class = "col s4"
      
      edit_button = row.add Link.new(nil, "<i class='tiny material-icons'>mode_edit</i>")
      edit_button.id = "edit_#{nic['id']}"
      edit_button.css_class = "btn-flat btn-tiny col s1"
      edit_button.on_click = "editMachineNetworkCard(#{machine['id']}, #{nic['id']});"

      delete_button = row.add Link.new(nil, "<i class='tiny material-icons'>delete</i>")
      delete_button.id = "delete_#{nic['id']}"
      delete_button.css_class = "btn-flat btn-tiny col s1"
      delete_button.on_click = "deleteMachineNetworkCard(#{nic['id']});"
    end
    
    entry_holder = self.add Div.new
    entry_holder.id = "entry_holder"
    entry_holder.css_class = "row"
    entry_holder.style = {display: "none"}
    
    button_holder = self.add Div.new
    button_holder.css_class = "row"
    
    add_button = button_holder.add Button.new "Add Card"
    add_button.css_class = "waves-effect waves-light btn"
    add_button.id = "add_nic_button"
    add_button.on_click = "showAddNicForm(#{machine['id']})"

  end
  
end
