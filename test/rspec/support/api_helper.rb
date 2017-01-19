module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
  
  def set_user_password(user, password)
    user.password = password
    user.password_confirmation = password
    user.save
    return user
  end
  
  def credentials_from_response(response)
    uid = response.headers['uid']
    token = response.headers['access-token']
    client = response.headers['client']
    return {credentials: {uid: uid, 'access-token' => token, client: client}}
  end
  
  def sign_in(user)
    conn = Faraday.new(:url => 'http://localhost:3000') do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    response = conn.post "/api/v1/auth/sign_in", "email=#{user[:email]}&password=#{user[:password]}"
    expect(response.status).to eq 200
    credentials = credentials_from_response(response)
    return credentials
  end
  
  def auth_connection
    conn = Faraday.new(:url => 'http://localhost:3000') do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    return conn
  end

  def reset_authentication_test_data
    conn = auth_connection
    response = conn.post "/api/reset_test_data", ""
    expect(response.status).to eq 200
  end
    
end



RSpec.configure do |config|
  config.include ApiHelper, :type=>:api #apply to all spec for apis folder
end