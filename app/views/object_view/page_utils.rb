require 'object_view'

class PageUtils

  def self.authenticity_token_hidden(session)
    authenticity_token = ObjectView::HiddenInput.new
    authenticity_token.name = "authenticity_token"
    authenticity_token.value = session['_csrf_token']
    return authenticity_token
  end

end