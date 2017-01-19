require "object_view"


class TopMenu < ObjectView::Div
  include ObjectView
  CONTENT = [
    {code: :account, address: "/accounts", label: "Account"},
    {code: :about, address: "/", label: "About"},
    {code: :machines, label: "Machines",
      children: [
        { code: :machine_list, address: '/account_home', label: "Summary"},
        { code: :machine_service, address: '/reports/service_location', label: "Services on Machines"}
      ]
    },
    {code: :networks,
      # address: "/networks",
      label: "Networks",
      children: [
        { code: :network_envs, address: '/networks', label: "Summary"},
        { code: :network_envs, address: '/networks/select_environments', label: "Environments"}
        ]
      },
    {code: :services, address: "/services", label: "Services"},
   # {code: :reports, address: "/reports", label: "Reports"},
    {code: :layout, address: "/machines/graphical_layout", label: "Layout"}
  ]
  
  
  def initialize(session, selected_item = :about)
    super()
    self.id = "side_menu"
    @selected_item = selected_item
    self.style = {height: "12px"}
    
    drop_downs = []
    menu_elements = []

    CONTENT.each do |menu_item_info|
      if (menu_item_info[:children])
        drop_down_trigger = Li.new
        if (menu_item_info[:code] == @selected_item)
          drop_down_trigger.css_class = "active"
        end

        link = drop_down_trigger.add Link.new "#!", menu_item_info[:label]
        link.css_class = "dropdown-button"
        link.add "<i class='material-icons right'>arrow_drop_down</i>"
        
        drop_down_id = "dropdown_#{drop_downs.length}"
        link.attr('data-activates', drop_down_id)
        menu_elements << drop_down_trigger
        
        drop_down_ul = Ul.new
        drop_down_ul.css_class = "dropdown-content"
        drop_down_ul.id = drop_down_id
        menu_item_info[:children].each do |child|
          li = drop_down_ul.add Li.new
          link = li.add Link.new(child[:address], child[:label])
        end
        
        drop_downs << drop_down_ul
      else
        menu_elements << create_menu_item_ui(menu_item_info)
      end
    end
    
    drop_downs.each do |drop_down|
      self.add drop_down
    end

    nav = self.add Nav.new
    nav_wrapper = nav.add Div.new
    nav_wrapper.css_class = "nav-wrapper"

    ul = nav_wrapper.add Ul.new
    ul.css_class = "right hide-on-med-and-down"
    menu_elements.each do |item|
      ul.add item
    end

    self.add "
        <script>
          $('.dropdown-button').dropdown();
        </script>
    "
  end
  
  def create_menu_item_ui(menu_item_info)
    item_ui = Li.new
    item_ui.add Link.new menu_item_info[:address], menu_item_info[:label]
    if (menu_item_info[:code] == @selected_item)
      item_ui.css_class = "active"
    end
    
    return item_ui
  end


  
end