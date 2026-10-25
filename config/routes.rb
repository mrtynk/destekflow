Rails.application.routes.draw do
  resources :tickets, only: %i[index show new create] do
    member do
      post :assign
      post :reply
      post :transition
      post :link_related
      delete :unlink_related
      post :analyze_with_rag
    end
  end
  resources :approval_requests, only: %i[index create] do
    member do
      post :approve
      post :reject
    end
    collection { post :run_escalation }
  end
  resource :agent_demo, only: :show do
    post :run
    post :repeat
  end
  namespace :internal do
    resources :agent_approval_requests, only: :create
    resources :agent_tickets, only: %i[create show]
  end
  root "tickets#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
