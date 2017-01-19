module UserHelper
  
  def login(email, password)
    visit "/"
    fill_in "email", with: email
    fill_in "password", with: password
    click_on "submit_credentials"
  end
  
end


RSpec.configuration.include UserHelper, :type => helper_module_include_type
