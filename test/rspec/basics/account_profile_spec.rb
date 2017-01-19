require_relative '../web_spec_helper'


feature "Account Profile" do
  

  context "Edit" do
    
    scenario "Admin user can see and edit account settings", js: true do
      session = {}
      user_hash = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user_hash}))
      login user.email, user_hash[:password]
      within "#side_menu" do
        click_on "Account"
      end

    end


    
  end
  
end