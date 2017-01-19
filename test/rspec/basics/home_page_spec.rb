require_relative '../web_spec_helper'


feature "Home Page" do
  

  context "Log In" do
    
    scenario "Displays login form if user isn't logged in", js: true do
      visit "/"
      fill_in "email", with: "bademail"
      fill_in "password", with: "badpass"
      click_on "submit_credentials"
      
      expect(page).to have_content("Incorrect email or incorrect password")
    end


    
  end
  
end