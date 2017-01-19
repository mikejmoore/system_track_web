#!/usr/bin/env ruby

require 'digest/md5'
require 'fileutils'
require 'byebug'
require 'json'
require 'base64'
require 'openssl'
require 'faraday'
require 'digest'
require_relative '../vendor/system_track_shared/utils/crypt_utils.rb'
require 'json'

SYSTEM_TRACK_HOST = "http://127.0.0.1:3000"

# Test: 
#  ansible ci2 -a "echo 'Hello'" -i ./scripts/ansible_hosts.rb -u operator --ask-pass

# Print copy of hosts file:
# ./scripts/ansible_hosts.rb --print

def connection(address)
    service_connection = Faraday.new(:url => "#{address}") do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      #faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    return service_connection
end

public_key = File.read(ENV['HOME'] + "/.ssh/id_rsa.pub")
pub_key_hash = CryptUtils.sha_hash_hex(public_key)

params = {:operation => "list", public_key_hash: pub_key_hash}
st_connection = connection(SYSTEM_TRACK_HOST)
response = st_connection.get "/v1/ansible_hosts", params

if (response.status == 200)
  cipher_info = JSON.parse(response.body)
  hosts_data = CryptUtils.decrypt_ansible_host_response(cipher_info)
  
  if (ARGV.include?("--print"))
    puts JSON.pretty_generate(JSON.parse(hosts_data))
  else
    STDOUT.puts hosts_data
  end
  exit 0
else
  STDOUT.puts "Error from server: #{response.body}"
  exit 1
end




