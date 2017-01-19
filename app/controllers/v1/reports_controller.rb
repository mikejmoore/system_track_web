require_relative "../../views/object_view/reports/reports_page"
require_relative "../../views/object_view/reports/services_locations_page"


class V1::ReportsController < ApplicationController
  before_action :validate_credentials
  skip_before_action :find_user_from_session
  
  def index
    page = ReportsPage.new(session)
    render text: page.render
  end
  
  def service_location
    options = {}
    if (params[:report])
      options[:report] = true
    end
    page = ServicesLocationsPage.new(session, options)
    render text: page.render()
  end

end