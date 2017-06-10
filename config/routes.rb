Rails.application.routes.draw do
  resources :posts
  resources :usuarios, as: :users,only: [:show,:update]
  resources :friendships, only: [:create,:update,:index]

  devise_for :users, controllers:{
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  post "/custom_sign_up", to: "users/omniauth_callbacks#custom_sign_up"

  #Para usuarios autenticados:
    authenticated :user do
        root 'main#home'
    end
  #Para usuarios no autenticados:
    unauthenticated :user do
        root 'main#unregistered'
    end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
  ActionCable.server.config.disable_request_forgery_protection = true
end
