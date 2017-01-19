require 'object_view'
require_relative '../page_utils'

class EnvironmentEntryRow < ObjectView::Div 
  include ObjectView
  include SystemTrack
  

  def initialize(session, index, environment = {})
    super()
    self.css_class = "row"
    self.id = "environment_row_#{index}"
    code = environment['code']
        
    input_holder = self.add Div.new
    input_holder.css_class = "input-field col s3"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "env_code_#{index}"
    edit.name = edit.id
    edit.css_class = "validate"
    edit.value = environment['code']
    label = input_holder.add Label.new "Code"
    label.for = edit.id
    
    input_holder = self.add Div.new
    input_holder.css_class = "input-field col s3"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "env_name_#{index}"
    edit.name = edit.id
    edit.css_class = "validate"
    edit.value = environment['name']
    label = input_holder.add Label.new "Name"
    label.for = edit.id
    
    input_holder = self.add Div.new
    input_holder.css_class = "input-field col s3"
    @category_combo = input_holder.add Combobox.new
    ["test", "production"].each do |category|
      option = @category_combo.option(category.titleize, category)
      if (environment['category'] == category)
        option.attr('selected', 'selected')
      end
    end
    @category_combo.id = "env_category_#{index}"
    @category_combo.name = @category_combo.id
    @category_combo.css_class = "validate"
    label = input_holder.add Label.new "Category"
    label.for = @category_combo.id

    button_holder = self.add Div.new
    button_holder.css_class = "col s3"
    submit_button = button_holder.add Div.new('Remove<i class="material-icons">cancel</i>')
    submit_button.id = "delete_env_#{index}"
    submit_button.css_class = "btn waves-effect waves-light red"
    submit_button.on_click = "deleteEnvironment('#{self.id}');"
    
    self.add initialization_javascript()
  end
  
  def initialization_javascript
    # When we add new environments using javascript, This script might be added again.  Running this initialization script a second time
    # will create a second combo box for categories.  Need to use initialization variable to make sure
    # this script runs only once.  Attaching the var to 'window' makes it global.
    initialize_variable_name = "window.#{@category_combo.id}_initialized"
    js = Javascript.new "
      if(typeof #{initialize_variable_name} == 'undefined') {
        $(document).ready(function() {
            $('##{@category_combo.id}').material_select();
            #{initialize_variable_name} = true;
         });
       }"
    return js
  end
  
end