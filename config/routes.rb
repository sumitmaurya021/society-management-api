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
        get 'maintenance_bills', to: 'buildings#maintenance_bills'
        get 'water_bills', to: 'buildings#water_bills'
        resources :maintenance_bills, only: [:create, :update, :index]
        resources :water_bills, only: [:create, :update, :index]
      end

      
      post 'login', to: 'users#login'
      post 'logout', to: 'users#logout'
      post 'verify_otp_and_login', to: 'users#verify_otp_and_login'
      post 'forgot_password', to: 'users#forgot_password'
      post 'reset_password', to: 'users#reset_password'
    end
  end
end
