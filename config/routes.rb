Rails.application.routes.draw do
  resources :appointments, only: [:index, :create]
  get '/schedule', to: 'appointments#schedule'
end
