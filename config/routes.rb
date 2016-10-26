Rails.application.routes.draw do
  # Login route
  get 'login/index'

  # Home routes i.e callbacks
  get '/' => 'home#index'
  get 'login/' => 'login#index'
  get 'callback/' => 'home#callback'
  get 'logout/' => 'home#logout'

  # Defaults
  root to: 'home#index'
  get "*path" => redirect('/')

  # Resources
  resources :discovery_metadata
end
