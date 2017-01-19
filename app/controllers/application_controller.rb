require 'faraday'
require_relative "../views/object_view/home_page.rb"
require_relative "../views/object_view/exception_page.rb"

class ApplicationController < ActionController::Base
  include SystemTrack
  include SystemTrack::ApplicationControllerModule
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  before_action :sign_on_if_credentials
  before_action :authenticate_token
  before_action :verify_authenticity_token
  before_action :find_user_from_session
  
  rescue_from Exception do |exception|
    web_exception_handler(exception)
  end  
  
  
  protected

  def web_exception_handler(exception)
    # Rails.logger.error "Exception: #{exception.message}"
    # exception.backtrace.each do |line|
    #   Rails.logger.error line
    # end
    if (exception.class == BadCredentialsException)
      bad_credentials()
    elsif (exception.class == CredentialsExpiredException)
      session[:user] = nil
      add_flash_message(:warning, "Credentials Expired")
      render text: {message: "Credentials Expired"}, status: 401
    else
      Rails.logger.error "#{exception.class} - #{exception.message}"
      puts "#{exception.class} - #{exception.message}"
      exception.backtrace.each do |line|
        Rails.logger.error line
        puts line
      end
      render text: ExceptionPage.new(session, exception), status: 500
    end
  end
  
  # def establish_csrf_if_needed
  #   if (session)
  #     session['_csrf_token'] ||= SecureRandom.base64(32)
  #   else
  #     Rails.logger.warn "Session doesn't exist"
  #   end
  # end
  
  #def verify_csrf
  # if (request.method == "POST")
  #   passed_csrf = request.headers['HTTP_X_CSRF_TOKEN']
  #   if (!passed_csrf == session['_csrf_token'])
  #     raise CsrfValidationException.new
  #   end
  # end
  #end
  
  def bad_credentials
    begin
      page = HomePage.new(session, {error: {type: :bad_credentials, message: "Unknown user or wrong password"}})
      render text: page.render()
    rescue
      render text: "Error", status: 500
     end
  end
  
end
