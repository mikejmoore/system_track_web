require_relative "../../views/object_view/account/account_entry_page"

class V1::AccountsController < ApplicationController
  before_action :validate_credentials, except: [:environment_row]
#  skip_before_action :validate_credentials, only: [:show_registration_form, :register, :logoff]
  # skip_before_action :authenticate_token
  # skip_before_action :verify_authenticity_token
  # skip_before_action :find_user_from_session, only: [:show_registration_form, :register, :logoff]

  def profile
    account_id = params[:account_id].to_i if (params[:account_id] != nil)
    account = SystemTrack::AccountsProxy.new.account(session, account_id)
    form = AccountEntryPage.new(session, account)
    render text: form.render
  end
  
  def environment_row
    index = params[:index].to_i
    row = EnvironmentEntryRow.new(session, index)
    render text: row.render
  end
  
  def save
    account_id = params[:id].to_i
    account = AccountsProxy.new.account(session, account_id)

    environments = []
    params.keys.each do |param_name|
      if (param_name.start_with? "env_name_")
        index = param_name["env_name_".length, param_name.length].to_i
        env = {
          name: params["env_name_#{index}"],
          code: params["env_code_#{index}"],
          category: params["env_category_#{index}"]
        }
        if (env[:name])
          environments << env
        end
      end
    end
    account['settings']['environments'] = environments
    
    account = AccountsProxy.new.save(session, account)
#    render text: account.to_json
    redirect_to "/account_home"
  end
  

end