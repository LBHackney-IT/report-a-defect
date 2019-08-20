Rails.application.routes.draw do
  get 'check' => 'application#check'
  get 'auth/oauth2/callback' => 'auth0#callback'
  get 'auth/failure' => 'auth0#failure'
  get 'sign_out' => 'application#sign_out'

  root to: 'application#welcome'

  get '/dashboard' => 'staff/dashboard#index'
  resources :estates, controller: 'staff/estates', only: %i[new create show] do
    resources :schemes, controller: 'staff/schemes', only: %i[new create show edit update] do
      resources :priorities, controller: 'staff/priorities', only: %i[new create]
      resources :properties, controller: 'staff/properties', only: %i[new create edit update]
      resources :communal_areas,
                controller: 'staff/communal_areas',
                only: %i[new create edit update]
    end
  end

  get 'search' => 'staff/searches#index'
  get 'report' => 'staff/report#index'
  get 'report/scheme/:id' => 'staff/report#show', as: :report_scheme

  resources :defects, controller: 'staff/defects' do
    resource :forward, controller: 'staff/defects/forwarding', only: %i[new create]
    resource :flag, controller: 'staff/defect_flags', only: %i[create destroy]
  end

  resources :properties, controller: 'staff/properties', only: %i[show] do
    resources :defects, controller: 'staff/property_defects', only: %i[new create show edit update]
  end

  resources :communal_areas, controller: 'staff/communal_areas', only: %i[show] do
    resources :defects,
              controller: 'staff/communal_defects',
              only: %i[new create show edit update] do
      resource :completion, controller: 'staff/communal_defects/completion', only: %i[new create]
    end
  end

  resources :defects, controller: 'contractor/defects' do
    resources :comments, controller: 'staff/comments', only: %i[new create edit update]
    get :accept
  end
end
