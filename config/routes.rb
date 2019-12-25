Rails.application.routes.draw do
  devise_for :users

  root to: 'pages#home'

  resources :google_calendar_configs, only: [:new, :create]
  resource :google_calendar_configs, only: :destroy
  get '/google_oauth_callback', to: 'google_calendar_configs#callback', as: 'google_oauth_callback'

  resources :google_calendars

  resources :events
end
