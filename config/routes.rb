Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :google_calendar_configs, only: [:new, :create]
  get '/google_oauth_callback', to: 'google_calendar_configs#callback', as: 'google_oauth_callback'
  resources :google_calendars, only: :index
end
