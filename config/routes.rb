Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  # Organization routes
  resources :organizations do
    member do
      patch :switch  # For switching between organizations
    end
    
    resources :projects do
      member do
        patch :archive
        patch :unarchive
      end
      
      resources :project_assignments, path: 'members', only: [:new, :create, :destroy]
      resources :project_files, path: 'files', only: [:index, :new, :create, :show, :destroy]
    end
    
    resources :invitations, except: [:edit, :update] do
      member do
        patch :resend
      end
    end
    
    resources :organization_members, path: 'members', only: [:index, :show, :update, :destroy]
  end
  
  # Public invitation acceptance (no authentication required)
  get '/invitations/:token/accept', to: 'invitations#accept', as: :accept_invitation
  
  # Dashboard/Home
  get '/dashboard', to: 'dashboard#index', as: :dashboard
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
