require 'object_view'
require_relative "./top_menu"
require_relative "./page_utils"

class BasePage < ObjectView::Page
  include ObjectView
  attr_accessor :current_user, :content, :right_content, :session
  
  def initialize(session, options = {})
    super()
    @asset_base_dir = "public"
    @session = session
    
    if (session[:user])
      @current_user = UserObject.new(session[:user])
    end
    @options = options
    
    header_dependencies
    @banner = body.add Div.new
    @banner.style = {background: "#222255", margin: "10px", padding: "5px"}
    @banner.css_class = "row"
    top_div = @banner.add Div.new
    top_div.css_class = "col s8"
    home_page_link = top_div.add Link.new "/", nil
    page_title = home_page_link.add Header.new 1, "Openlogic IT Topology"
    page_title.style = {color: "#eeeeee", font_size: "24px"}
    
    if (!@options[:report])
      user_div = @banner.add Div.new
      user_div.css_class = "col s3"
      user_div.style = {background: "#aaaa66"}
      user_div.id = "user_div"
    
      self.head.add "<meta content='authenticity_token' name='csrf-param'>"
      self.head.add "<meta content='#{session['_csrf_token']}' name='csrf-token'>"
    end
    
    @content = body.add Div.new
    show_flash_messages()
    @content.style = {width: "100%", background: "#fffff", margin: "10px", padding: "5px"}
  
    div = @content.add Div.new
    div.style = {width: "400px"}
    div.css_class = "row"
    
    if (!@options[:report])
    
      if (@options[:no_user] == nil) || (@options[:no_user] == false)
        if (@current_user == nil)
          show_login_section(user_div)
        else
          show_signed_in_user(user_div)
        end
      end
    end
    
    main_row = @content.add Div.new
    main_row.css_class = "row"
    
    @right_content = main_row.add Div.new
    @right_content.id = "right_content"
    @right_content.css_class = "col s12"
  end
  
  def show_flash_messages
    return if (@options[:report])
    if (@session[:flash_messages] != nil)
      @session[:flash_messages].keys.each do |severity|
        @session[:flash_messages][severity].each do |message|
          message_font = @content.add Span.new("#{severity.to_s.titleize}: #{message}")
          if (severity == "warning")
            message_font.style = {font_size: "12px", color: "#bb9900", width: "300px"}
          elsif (severity == "error")
            message_font.style = {font_size: "12px", color: "#bb0000", width: "300px"}
          else
            message_font.style = {font_size: "12px", color: "#222222", width: "300px"}
          end
        end
      end
    else
      message_font = @content.add Span.new("No Flash Messages")
      
    end
    
    @session[:flash_messages] = nil
  end
  

  def add_java_script_file(path)
    if (@options[:report])
      file_contents = File.read(@asset_base_dir + path)
      self.head.add Javascript.new(file_contents)
    else
      self.body.add JavascriptFile.new("/javascripts/materialize.js")
    end
  end

  def add_css_file(path)
    if (@options[:report])
      file_contents = File.read(@asset_base_dir + path)
      self.head.add "<style>
              #{file_contents}
          </style>"
    else
      self.head.add "<link rel='stylesheet' type='text/css' href='#{path}?body=#{Time.now.to_i}'/>"
    end
  end
  
  def header_dependencies
    self.body.add JavascriptFile.new("https://code.jquery.com/jquery-1.12.3.min.js")
    add_java_script_file("/javascripts/materialize.js")
    add_java_script_file("/javascripts/application.js")
    add_java_script_file("/javascripts/redirects.js")
    add_java_script_file("/javascripts/init.js")
    add_java_script_file("/javascripts/jquery.materialize-autocomplete.min.js")
    add_java_script_file("/javascripts/datatable/jquery.dataTables.min.js")
    add_java_script_file("/javascripts/datatable/fnReloadAjax.js")


    add_css_file '/stylesheets/application.css'
    add_css_file '/stylesheets/jquery.dataTables.customized.css'
    self.head.add('<link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>')
    add_css_file('/stylesheets/style.css')
    add_css_file('/stylesheets/materialize.css')
    add_css_file('/stylesheets/wide_table.css')
    self.head.add "<!--Let browser know website is optimized for mobile-->
          <meta name='viewport' content='width=device-width, initial-scale=1.0'/>"
  end
  
  def authenticity_token_hidden
    return PageUtils.authenticity_token_hidden(@session)
  end
  
  def show_login_section(user_div)
    if (@options[:error] != nil) && (@options[:error][:type] == :bad_credentials)
      error_text = user_div.add Font.new("Incorrect email or incorrect password")
      error_text.style = {color: "#bb2222"}
    end
    login_form = user_div.add Form.new
    login_form.action = "/sign_in"
    login_table = login_form.add Table.new
    login_table.style = {width: "300px"}
    email_label = Span.new "Email"
    password_label = Span.new "Password"
    
    login_form.add authenticity_token_hidden
    
    email_input = TextInput.new
    email_input.name = "email"
    email_input.id = "email"
    email_input.style = {width: "160px", height: "18px", border: "1px solid #aaaabb", background: "#ffffff", font_size: "11px"}

    password_input = TextInput.new
    password_input.type = "password"
    password_input.name = "password"
    password_input.id = "password"
    password_input.style = {width: "120px", height: "18px", border: "1px solid #aaaabb", background: "#ffffff"}
    
    sign_in_button = Submit.new("Submit")
    sign_in_button.name = "login"
    sign_in_button.id = "submit_credentials"
    sign_in_button.css_class = "waves-effect waves-light btn"
    
    login_table.row([email_label, password_label, ""])
    login_table.row([email_input, password_input, sign_in_button])
    
    sign_in_button = user_div.add Link.new("/user/show_registration_form", "Register")
    sign_in_button.id = "register"
    sign_in_button.css_class = "waves-effect waves-light btn"
  end
  
  def show_signed_in_user(user_div)
    row = user_div.add Div.new
    row.css_class = "row"
    name_span = row.add Span.new("#{@current_user.first_name} #{@current_user.last_name}")
    name_span.style = {font_size: "18px"}

    row = user_div.add Div.new
    row.css_class = "row"
    logoff_button = row.add Link.new("/logoff", "Log Off")
    logoff_button.id = "logoff"
    logoff_button.css_class = "waves-effect waves-light btn"
    logoff_button.style = {font_size: "12px"}
  end
  
  def create_main_menu(session, select_symbol)
    return if (@options[:report])

    row = @banner.add Div.new
    row.css_class = "row"
    row.style = {margin_bottom: '0px', margin_left: '0px', margin_right: '0px'}
    
    menu_holder = row.add Div.new
    menu_holder.css_class = "col s12"
    menu_holder.add TopMenu.new(session, select_symbol)
  end
  

  
end