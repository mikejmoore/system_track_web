require_relative '../web_spec_helper'
include SystemTrack

feature "Valid user can sign in, sign out", js: true do
  scenario "Test Super User can login" do
    login(TestConstants::SUPER_USER[:email], TestConstants::SUPER_USER[:password])
    expect(page).to have_content("Super User")
  end
  
  scenario "Logging on takes user to summary page" do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user_hash}))

    login(user[:email], "secret123")
    expect(page).to have_content("ADD MACHINE")
    within "#user_div" do
      expect(page).to have_no_content("Incorrect email or incorrect password")
      expect(page).to have_content(user[:first_name])
      expect(page).to have_content(user[:last_name])
    end
  end

  scenario "Bad credentials will give error message when attempting to sign in" do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))

    login(user[:email], "badpassword")
    within "#user_div" do
      expect(page).to have_content("Incorrect email or incorrect password")
    end
  end
  
  scenario "Logging off takes user to home (info) page" do
    session = {}
    user_hash = unregistered_user
    user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
    login user.email, user_hash[:password]
    
    visit "/"
    click_on "logoff"
    within "#user_div" do
      expect(page).to have_css("form")
    end
  end
  
  
end
