Rails.application.routes.draw do
  # WhatsApp webhook endpoints
  post '/webhook/whatsapp', to: 'whatsapp_webhook#receive_message'
  get '/webhook/whatsapp', to: 'whatsapp_webhook#verify_webhook'

  # Public presence confirmation API
  resources :presences, only: [:index, :create] do
    collection do
      delete ':nickname', to: 'presences#destroy', as: :cancel
    end
  end

  # Admin API
  namespace :admin do
    resources :users
    resources :daily_lists do
      member do
        post :send_to_whatsapp
      end
    end
    
    # Admin dashboard endpoints
    get :dashboard, to: 'dashboard#index'
  end

  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }
  
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ message: 'Dota Evolution Presence API', version: '1.0' }.to_json]] }
end
