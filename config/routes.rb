Rails.application.routes.draw do
  root to: 'staff/dashboard#index'
  get 'check' => 'application#check'
  resources :schemes, controller: 'staff/schemes', only: %i[new create show] do
    resources :priorities, controller: 'staff/priorities', only: %i[new create]
  end
end
