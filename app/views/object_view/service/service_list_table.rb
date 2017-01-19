require "object_view"

class ServiceListTable < ObjectView::Table
  include ObjectView
  include SystemTrack
  

  def initialize(session, account_id)
    super()
    items = MachinesProxy.new.service_list(session, account_id)
    
    table = self
    table.style = {padding_left: "5px", padding_right: "5px"}
    table.css_class = "dataTable"
    table.id = "service_table"
    table.head(["Name", "Code", ""])
    table.foot(["Name", "Code", ""]) if (items.length > 0)
    self.add Javascript.new "
      $(document).ready( function () {
         $('#service_table').DataTable({
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
    items.each do |item|
      edit_button = Button.new "Edit"
      edit_button.css_class = "waves-effect waves-light btn"
      edit_button.id = "edit_service_button_#{item['id']}"
      edit_button.on_click = "showAddServiceForm(#{item['id']})"
      edit_button.style = {
          height: '16px',
          line_height: '14px'
      }
      
      table.row([item['name'], item['code'], edit_button])
    end
  end
  
end
