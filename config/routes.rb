Rails.application.routes.draw do
  root to: 'visitors#index'
  resource :repairs
end
