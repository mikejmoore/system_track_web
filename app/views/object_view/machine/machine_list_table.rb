require "object_view"

class MachineListTable < ObjectView::Table
  include ObjectView

  def initialize(session, account_id)
    super()
    table = self
    items = SystemTrack::MachinesProxy.new.machine_list(session, account_id)
    table.style = {padding_left: "5px", padding_right: "5px"}
    table.css_class = "dataTable"
    table.id = "machine_table"
    table.head(["Code", "Name", "IP Address", "Status", "Purchased", ""])
    table.foot(["Code", "Name", "IP Address", "Status", "Purchased", ""]) if (items.length > 5)
    self.add Javascript.new "
      $(document).ready( function () {
         $('#machine_table').DataTable({
           'scrollY':        '400px',
           'scrollCollapse': true,
           'paging':         false
           }
         ); // dataTable
         $(\"[name='machine_table_length']\").show();
         $(\"[name='machine_table_length']\").css('height', '1.5rem');
      }
      );  //ready
    "
    items.each do |machine|
      view_button = Link.new "/v1/machines/show?machine_id=#{machine['id']}", "<i class='tiny material-icons'>mode_edit</i>"
      view_button.css_class = "btn-flat btn-tiny col s3"
      view_button.id = "view_machine_button_#{machine['id']}"
      
      
      # delete_button = row.add Link.new(nil, "<i class='tiny material-icons'>delete</i>")
      # delete_button.id = "delete_#{nic['id']}"
      # delete_button.css_class = "btn-flat btn-tiny col s1"
      # delete_button.on_click = "deleteMachineNetworkCard(#{nic['id']});"
      
      purchase_date = ""
      purchase_date = Date.parse(machine['purchase_date']).strftime("%Y-%M-%D") if (machine['purchase_date'])
      table.row([machine['code'], machine['name'], machine['ip_address'], machine['status'].titleize, purchase_date, view_button])
    end
  end
  
end
