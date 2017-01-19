require_relative "./base_page"

class RegistrationPage < BasePage
  include ObjectView
  
  def initialize(session, options = {})
    
    options.merge!({no_user: true})
    super(session, options)
    
    registration_holder_div = self.content.add Div.new
    registration_holder_div.css_class = "row"
    registration_holder_div.style = {border_radius: "4px", background: "white", width: "600px"}
    form = registration_holder_div.add Form.new
    form.css_class = "col s12"
    form.id = "registration_form"
    form.action = "/users/register"

    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "email"
    edit.name = "email"
    edit.css_class = "validate"
    label = input_holder.add Label.new "Email"
    label.for = "email"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    edit.id = "email_confirm"
    edit.name = "email_confirm"
    edit.css_class = "validate"
    label = input_holder.add Label.new "Confirm Email"
    label.for = "email_confirm"


    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    #edit.attr("placeholder", "Placeholder")
    edit.type = "text"
    edit.name = "first_name"
    edit.id = "first_name"
    edit.css_class = "validate"
    label = input_holder.add Label.new "First Name"
    label.for = "first_name"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "text"
    #edit.attr("placeholder", "Placeholder")
    edit.id = "last_name"
    edit.name = "last_name"
    edit.css_class = "validate"
    label = input_holder.add Label.new "Last Name"
    label.for = "last_name"


    row = form.add Div.new
    row.css_class = "row"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "password"
    edit.id = "password"
    edit.name = "password"
    edit.css_class = "validate"
    label = input_holder.add Label.new "Password"
    label.for = "password"
    
    input_holder = row.add Div.new
    input_holder.css_class = "input-field col s6"
    edit = input_holder.add TextInput.new
    edit.type = "password"
    edit.id = "password_confirm"
    edit.name = "password_confirm"
    edit.css_class = "validate"
    label = input_holder.add Label.new "Confirm Password"
    label.for = "password_confirm"
    
    
    row = form.add Div.new
    row.css_class = "row"
    
    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    submit_button = button_holder.add Submit.new("Submit")
    submit_button.id = "submit"
    submit_button.name = "submit"
    submit_button.css_class = "waves-effect waves-light btn"

    button_holder = row.add Div.new
    button_holder.css_class = "col s3"
    cancel_button = button_holder.add Submit.new("Cancel")
    cancel_button.id = "cancel"
    cancel_button.name = "cancel"
    cancel_button.css_class = "waves-effect waves-light btn"
    cancel_button.style = {padding_left: "10px"}
    
  end
  
  
end