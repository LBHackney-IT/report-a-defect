Rails.application.routes.draw do
  root to: 'staff/dashboards#index'
  get 'check' => 'application#check'
  resource :schemes, controller: 'staff/schemes'
end
