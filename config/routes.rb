Rails.application.routes.draw do
  
  get  '/' => 'v1/information#index'
  
  get   '/accounts' => 'v1/accounts#profile'
  get   '/accounts/environment_row' => 'v1/accounts#environment_row'
  post  '/accounts/save' => 'v1/accounts#save'

  post '/account_home' => 'v1/machines#summary'
  get  '/account_home' => 'v1/machines#summary'
  get  '/user/show_registration_form' => "v1/users#show_registration_form"
  post '/users/register' => 'v1/users#register'
  get  '/logoff' => 'v1/users#logoff'
  
  post '/sign_in' => 'v1/users#sign_in'
  
  post 'v1/machines/save' => 'v1/machines#save'
  get  'v1/machines/table_ajax' => 'v1/machines#table_ajax'
  get  'v1/machines/graphical_layout' => 'v1/machines#graphical_layout'
  get  'v1/machines/edit_form_ajax' => "v1/machines#edit_form_ajax"
  get  'v1/machines/view_form_ajax'
  post '/v1/machines/toggle_service' => 'v1/machines#toggle_service'
  get  '/v1/machines/show'
  get  '/v1/machines/edit_machine'
  get  '/v1/machines/nic_edit_form_ajax' => "v1/machines#nic_edit_form_ajax"
  post '/v1/machines/save_network_card'
  delete '/v1/machines/delete_network_card'
  
  get  '/v1/ansible_hosts' => "v1/machines#ansible_hosts"

  post '/networks/save'  => 'v1/networks#save'
  get  '/networks' => 'v1/networks#summary'
  get  '/networks/table_ajax' => 'v1/networks#table_ajax'
  get  '/networks/edit_form_ajax' => "v1/networks#edit_form_ajax"

  post '/services/save'  => 'v1/services#save'
  get  '/services' => 'v1/services#summary'
  get  '/services/table_ajax' => 'v1/services#table_ajax'
  get  '/services/edit_form_ajax' => "v1/services#edit_form_ajax"
  
  get 'reports' => 'v1/reports#index'
  get 'reports/service_location' => 'v1/reports#service_location'
  
end
