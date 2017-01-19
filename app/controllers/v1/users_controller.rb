require_relative "../../views/object_view/summary_page"
require_relative "../../views/object_view/registration_page"

class V1::UsersController < ApplicationController
  skip_before_action :sign_on_if_credentials, only: [:show_registration_form, :register, :logoff]
  skip_before_action :authenticate_token
  skip_before_action :verify_authenticity_token
  skip_before_action :find_user_from_session, only: [:show_registration_form, :register, :logoff]
  
  
  def sign_in
    page = SummaryPage.new(session)
    render text: page.render()
  end
  
  
  def show_registration_form
    registration_page = RegistrationPage.new(session)
    render text: registration_page.render
  end
  
  def register
    Rails.logger.info "register"
    if (params[:cancel] == "Cancel")
      redirect_to "/"
    else
      user = {
        email: params[:email],
        password: params[:password],
        first_name: params[:first_name],
        last_name: params[:last_name]
      }
      create_params = {user: user}

      UsersProxy.new.register(session, create_params)
      page = SummaryPage.new(session)
      render text: page.render
    end
  end
  
  def logoff
    UsersProxy.new.logoff(session)
    render text: HomePage.new(session).render
  end
  
end