require_relative "../base_page"
require_relative "./account_entry_form"


class AccountEntryPage < BasePage
  include SystemTrack
  
  def initialize(session, account, options = {})
    super(session, options)
    self.body.add JavascriptFile.new("/javascripts/account.js")
    
    # Later: check session['user']['roles'] to make sure user is admin in order to edit
    
    create_main_menu(session, :account)
    @right_content.add AccountEntryForm.new(session, account)
  end


end