require "object_view"
require "system_track_shared"

class NetworkListTable < ObjectView::Table
  include ObjectView
  include SystemTrack

  def initialize(session, account_id)
    super()
    items = MachinesProxy.new.network_list(session, account_id)
    
    table = self
    table.style = {padding_left: "5px", padding_right: "5px"}
    table.css_class = "dataTable"
    table.id = "network_table"
    table.head(["Name", "Address", "Mask", ""])
    table.foot(["Name", "Address", "Mask", ""]) if (items.length > 0)
    self.add Javascript.new "
      $(document).ready( function () {
         $('#network_table').DataTable({
           'scrollY':        '400px',
           'scrollCollapse': true,
           'paging':         false
           }
         ); // dataTable
         $(\"[name='machine_table_length']\").show();
         $(\"[name='machine_table_length']\").css('height', '1.5rem');
      //   $(\"[name='machine_table_length']\").material_select();
      //   alert('Done');
      }
      );  //ready
    "
    items.each do |network|
      edit_button = Button.new "Edit"
      edit_button.css_class = "waves-effect waves-light btn"
      edit_button.id = "edit_network_button_#{network['id']}"
      edit_button.on_click = "showAddNetworkForm(#{network['id']})"
      edit_button.style = {
          height: '16px',
          line_height: '14px'
      }
      
      table.row([network['name'], network['address'], network['mask'], edit_button])
    end
  end
  
end
