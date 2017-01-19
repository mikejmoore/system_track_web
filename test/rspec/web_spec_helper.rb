ENV["RAILS_ENV"] ||= "test"
ENV['BROWSER'] ||= "firefox"
  
def helper_module_include_type
  #return :request
  return :feature 
end 

require_relative "../../config/environment"
require 'rspec'
require 'random_word'
require 'byebug'

require 'capybara'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/email/rspec'
#require 'capybara/poltergeist'


include SystemTrack

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}



def server_address(page)
  if (page.current_url)
    visit_home_page
  end  
  current_url = page.current_url
  server_address = extract_server_address(current_url)
  puts "SERVER: #{server_address}"
  return server_address
end

def extract_server_address(long_url)
  url_parts = long_url.split("/")
  server_address = url_parts[0] + "//" + url_parts[2]
  return server_address
end

def not_implemented
  pending("Not Implemented") {
    raise "Not Implemented"
  }
end

def refresh_page 
  visit page.current_path
end

def truncate_database()
  response = SystemTrack::UsersProxy.new.service_connection.post "/test/reset", {}
  raise "Unsuccessful user test data reset" if response.status != 200

  response = SystemTrack::MachinesProxy.new.service_connection.post "/test/reset", {}
  raise "Unsuccessful user test data reset" if response.status != 200
end


def has_matching_attribute?(selector, attribute, value)
  page.all(selector).any? do |elem|
    elem[attribute] =~ value
  end
end



if ENV['REMOTE_SERVER'] != nil
  Capybara.server_host = ENV['REMOTE_SERVER'] #using this to run test on grid2
end

puts "Running acceptance tests against #{(Capybara.server_host || 'localhost').inspect}"


Capybara.default_wait_time = 15


ActionController::Base.class_eval do
  def rescue_action(exception)
    raise exception
  end
end



browser = ENV['browser']
if (browser == nil)
  browser = ENV['BROWSER']
end
puts "Browser: #{browser}"
if (browser != nil)
  browser = browser.to_sym
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => browser)
  end                                    
else
  Capybara.default_driver = ENV.fetch('CAPYBARA_DRIVER',
                                      if Capybara.app_host
                                        :selenium
                                      else
                                        Capybara.default_driver
                                      end).to_sym
end
 


if ENV['REMOTE_SERVER'] != nil
  ## Chrome Remote driver definition
  chrome_switches = %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate]
  caps_opts = {'chrome.switches' => chrome_switches}
  chrome_caps = Selenium::WebDriver::Remote::Capabilities.chrome(caps_opts)
  chrome_opts = {
    :browser => :remote,
    :url => grid2_hub_url,
    :desired_capabilities => chrome_caps
  }
  # opts[:desired_capabilities] = chrome_caps

  Capybara.register_driver :remote_selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, chrome_opts)
  end  

  ## Internet Explorer Remote driver definition
  ie_caps = Selenium::WebDriver::Remote::Capabilities.ie()
  ie_opts = {
    :browser => :remote,
    :url => grid2_hub_url,
    :desired_capabilities => ie_caps
  }

  Capybara.register_driver :remote_selenium_ie do |app|
    Capybara::Selenium::Driver.new(app, ie_opts)
  end

  ## Firefox Remote driver definition
  ff_caps = Selenium::WebDriver::Remote::Capabilities.firefox()
  opts[:desired_capabilities] = ff_caps

  Capybara.register_driver :remote_selenium_ff do |app|
    Capybara::Selenium::Driver.new(app, opts)
  end

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, opts)
  end


  case ENV['BROWSER']
  when "chrome"
    Capybara.javascript_driver = :remote_selenium_chrome
  when "ie"
    Capybara.javascript_driver = :remote_selenium_ie
  when "firefox"
    Capybara.javascript_driver = :remote_selenium_ff
  else
    puts "BROWSER should be one of [chrome, ie, firefox]"
  end

  Capybara.default_driver = :remote_selenium_ff

end

Capybara.default_wait_time = 10
puts "Capybara default wait time: " + Capybara.default_wait_time.to_s



RSpec.configure do |config|
  config.include LoggingHelper

  config.before :each do
    puts "Before Scenario...."
  end

  config.before(:suite) do
    puts "Before Suite...."
    @time_after_home_page = nil
    @start_time = Time.now
    truncate_database()
  end
  
  config.before :all do
    @time_after_home_page = nil
    @start_time = Time.now
  end
  
  config.after :all do
    @end_time = Time.now
    @elapsed_time = @end_time - @start_time
    
    puts "Closing the browser too quick causes error due to pop up."
    sleep 2
    info("Elapsed time: " + @elapsed_time.to_s)
  end
  
  config.after(:suite) do
#      DatabaseCleaner.clean_with :truncation
  end
  
end
