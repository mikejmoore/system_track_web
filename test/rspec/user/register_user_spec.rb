require_relative '../web_spec_helper'



feature "Register User Spec", js: true do

  scenario "From home page" do
    visit "/"
    expect(page).to have_content("")
    
    expect(page).to have_css("#register")
    click_on "Register"
    
    expect(page).to have_content("Confirm Email")
    user = unregistered_user
    user[:email] = "#{user[:first_name]}.#{user[:last_name]}@bigcorp.com"
    fill_in "first_name", with: user[:first_name]
    fill_in "last_name", with: user[:last_name]
    fill_in "email", with: user[:email]
    fill_in "email_confirm", with: user[:email]
    fill_in "password", with: user[:password]
    fill_in "password_confirm", with: user[:password]
    within "#registration_form" do
      click_on "Submit"
    end

    puts "After logging in, user should be displayed and option to log off available"
    visit "/"
    within "#user_div" do
      expect(page).to have_content("#{user[:first_name]}")
      expect(page).to have_content("#{user[:last_name]}")
      expect(page).to have_content("LOG OFF")
      click_on "Log Off"
    end

    puts "After logging out, user should no longer be displayed and option to log in available"
    visit "/"
    within "#user_div" do
      expect(page).to_not have_content("#{user[:first_name]}")
      expect(page).to_not have_content("#{user[:last_name]}")
      expect(page).to_not have_content("LOG OFF")
    end
    
    fill_in "email", with: user[:email]
    fill_in "password", with: user[:password]
    
    click_on "submit_credentials"
    
    within "#user_div" do
      expect(page).to have_content("#{user[:first_name]}")
      expect(page).to have_content("#{user[:last_name]}")
      expect(page).to have_content("LOG OFF")
    end
  end
  
end