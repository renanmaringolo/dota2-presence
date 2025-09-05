Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes with Graphiti pattern
  scope path: ApplicationResource.endpoint_namespace, defaults: { format: :jsonapi } do
    # Authentication routes (custom endpoints)
    post '/auth/register', to: 'api/v1/auth#register'
    post '/auth/login', to: 'api/v1/auth#login'
    get '/auth/me', to: 'api/v1/auth#me'
    
    # Daily Lists routes
    get '/daily-lists/dashboard', to: 'api/v1/daily_lists#dashboard'
    
    # Presences routes
    post '/presences', to: 'api/v1/presences#create'
    delete '/presences/:list_type', to: 'api/v1/presences#destroy'
    
  end

  # Defines the root path route ("/")
  root "rails/health#show"
end
