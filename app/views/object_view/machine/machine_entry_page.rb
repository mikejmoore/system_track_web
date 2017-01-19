require_relative "../base_page"
require_relative "./machine_nic_table"


class MachineEntryPage < BasePage
  include SystemTrack
  
  def initialize(session, machine = nil, options = {})
    super(session, options)
    self.body.add JavascriptFile.new("/javascripts/machine.js")
    
    @right_content.add MachineEntryForm.new(session, machine, :edit)
    
  end
  
end