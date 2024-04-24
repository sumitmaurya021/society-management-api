Rails.application.routes.draw do
  devise_for :users
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  namespace :api do
    namespace :v1 do
      resources :users
      resources :buildings do
        resources :blocks do
          resources :floors do
            resources :rooms
          end
        end
      end
      
      post 'login', to: 'users#login'
      post 'logout', to: 'users#logout'
      post 'verify_otp_and_login', to: 'users#verify_otp_and_login'
      post 'forgot_password', to: 'users#forgot_password'
      post 'reset_password', to: 'users#reset_password'
    end
  end
end
