Rails.application.routes.draw do
  root to: 'staff/dashboard#index'
  get 'check' => 'application#check'
  resources :estates, controller: 'staff/estates', only: %i[new create show] do
    resources :schemes, controller: 'staff/schemes', only: %i[new create show] do
      resources :priorities, controller: 'staff/priorities', only: %i[new create]
      resources :properties, controller: 'staff/properties', only: %i[new create edit update]
    end
  end
end
