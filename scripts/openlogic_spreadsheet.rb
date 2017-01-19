#!/usr/bin/env ruby

require_relative './../config/environment'
require_relative './../app/views/object_view/reports/services_location_spreadsheet'

require 'byebug'
require 'spreadsheet'

include SystemTrack

class OpenlogicSpreadsheet
  
  def initialize(user_email, password)
    user_service = UsersProxy.new
    accounts_service = AccountsProxy.new
    machine_service = MachinesProxy.new
    user_service.ping
    @session = {}

    user = user_service.sign_in(@session, user_email, password)
    account = accounts_service.account(@session, user['account_id'])
    
    # Spreadsheet.client_encoding = 'UTF-8'
    # book = Spreadsheet::Workbook.new
    # head_format = Spreadsheet::Format.new :color => :black,
    #                                  :weight => :bold,
    #                                  :size => 12
    # sheet_1 = book.create_worksheet name: "Epic Tasks"
    # sheet_1.row(0).default_format = head_format
    # sheet_1.row(0).push "Epic", "Created", "Status", "Summary"
    # row_index = 1
    # (1..5).each do |index|
    #   row = sheet_1.row(row_index)
    #   row.push "Value 1", "Value 2", "Value 3", "Value 4"
    #   row_index += 1
    # end
    # book.write "log/ops_qa_tasks.xls"

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    head_format = Spreadsheet::Format.new color: :black, weight: :bold, size: 12
    @services = MachinesProxy.new.service_list(@session)
    @networks = MachinesProxy.new.networks_add_machines(@session)

    @networks.sort! {|a, b| a['padded_address'] <=> b['padded_address']}
    @networks.each do |network| 
      ServicesLocationSpreadsheet.new(book, network, @services)
    end
    file_name = "machine_services"
    book.write "log/#{file_name}.xls"
  end
end
  

user = ARGV.first
password = ARGV.last

OpenlogicSpreadsheet.new(user, password)
puts "Done"

