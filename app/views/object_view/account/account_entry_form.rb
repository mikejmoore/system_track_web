require 'object_view'
require_relative '../page_utils'
require_relative "./environment_entry_row"

class AccountEntryForm < ObjectView::Div 
  include ObjectView
  include SystemTrack
  

  def initialize(session, account = nil)
    super()
    
    account_id = nil
    
    self.id = "account_form_holder"
    self.style = {background: "#ffffff", border_radius: "5px", width: "90%", margin_bottom: "20px", margin_top: "20px"}
    
    form = self.add Form.new
    form.css_class = "col s12"
    form.id = "account_form"
    form.style = {width: "100%", margin_bottom: "0px", padding_bottom: "0px"}
    form.action = "/accounts/save"

    id_hidden = form.add HiddenInput.new
    id_hidden.name = "id"
    id_hidden.value = account['id'].to_s

    form.add PageUtils.authenticity_token_hidden(session)

    row = form.add Div.new
    row.css_class = "row"
    row.add Span.new("<h4>General</h4>")

    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "name"
    edit.name = "name"
    edit.css_class = "validate"
    edit.value = account['name'] if (account)
    label = input_holder.add Label.new "Name"
    label.for = "name"

    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "code"
    edit.name = "code"
    edit.css_class = "validate"
    edit.value = account['code'] if (account)
    label = input_holder.add Label.new "Code"
    label.for = "code"
 
    env_section_row = form.add Div.new
    row.css_class = "row z-depth-1"
 
    row = env_section_row.add Div.new
    row.css_class = "row"
    row.add Span.new("<h4>Environments</h4>")
    
    env_holder = env_section_row.add Div.new
    env_holder.id = "environments_holder"
    env_holder.css_class = "row"
    
    if (account)
      environments = account['settings']['environments']
      index = 0
      environments.each do |environment|
        env_holder.add EnvironmentEntryRow.new(session, index, environment)
        index += 1
      end
    end
    row = env_section_row.add Div.new
    row.css_class = "row"

    button_holder = row.add Div.new
    button_holder.css_class = "col s2"
    add_env_button = button_holder.add Div.new('Add Environment<i class="material-icons right">add</i>')
    add_env_button.id = "add_env"
    add_env_button.css_class = "btn waves-effect waves-teal"
    add_env_button.on_click = "addEnvironmentEntry();"
 
    #row.style = {margin_bottom: "0px"}
    
    row = form.add Div.new
    row.css_class = "row"
    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    submit_button = button_holder.add Button.new("Submit")
    submit_button.id = "submit"
    submit_button.css_class = "waves-effect waves-light btn"
    submit_button.on_click = "submitNetworkCreateForm();"

    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    cancel_button = button_holder.add Div.new("Cancel")
    cancel_button.id = "cancel"
    cancel_url = "/account_home"
    cancel_button.on_click = "javascript:q=(document.location.href);void(open('#{cancel_url}?url='+escape(q),'_self','resizable,location,menubar,toolbar,scrollbars,status'));"
    cancel_button.css_class = "waves-effect waves-light btn"
    cancel_button.style = {padding_left: "10px", padding_bottom: "10px"}

    row = form.add Div.new
    row.css_class = "row"
    
    self.add Javascript.new "
    $(document).ready(function() {
        Materialize.updateTextFields();
    });"
    
  end
  
end