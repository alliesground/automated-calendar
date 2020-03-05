require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users

  root to: 'pages#home'

  resources :google_calendar_configs, only: [:new, :create]
  resource :google_calendar_configs, only: :destroy
  get '/google_oauth_callback', to: 'google_calendar_configs#callback', as: 'google_oauth_callback'

  resources :google_calendars

  resources :events

  resources :outbound_event_configs, only: [:new, :create, :destroy]

  resources :users, only: :index

  resources :import_google_calendars, only: :index
end
