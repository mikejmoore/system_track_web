require_relative "../../views/object_view/home_page"
require_relative "../../views/object_view/summary_page"

class V1::InformationController < ApplicationController
  skip_before_action :validate_credentials, only: [:index]
  skip_before_action :verify_csrf
  # skip_before_action :sign_on_if_credentials, only: [:index]
  
  def index
    page = HomePage.new(session)
    render text: page.render()
  end
  
  
end