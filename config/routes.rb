Rails.application.routes.draw do
  devise_for :users
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  namespace :api do
    namespace :v1 do
      resources :users
      
      post 'login', to: 'users#login'
      post 'logout', to: 'users#logout'
      post 'verify_and_generate_token', to: 'users#verify_and_generate_token'
    end
  end

end
