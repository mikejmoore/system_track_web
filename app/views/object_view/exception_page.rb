require_relative "./base_page"

class ExceptionPage < BasePage
  include 
  
  def initialize(session, exception, options = {})
    super(session, options)
    if (ENV['RAILS_ENV'] != "production")
      self.content.add "<h1>An Error Occurred</h1>"
    else
      self.content.add exception.message
      exception.backtrace.each do |line|
        self.content.add line
        self.content.add "<br/>"
      end
      
    end
    
  end
  
end