Rails.application.routes.draw do
  root to: 'visitors#index'
  get 'check' => 'application#check'
  resource :repairs
end
