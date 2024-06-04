Rails.application.routes.draw do

  mount ActionCable.server => '/cable'

  devise_for :users
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :update, :destroy] do
        resources :notifications, only: [:index, :show, :create]
      end
      resources :buildings do
        resources :blocks do
          resources :floors do
            resources :rooms do
              post 'update_units', to: 'water_bills#update_units'
            end
          end
        end
        get 'maintenance_bills', to: 'buildings#maintenance_bills'
        get 'water_bills', to: 'buildings#water_bills'
        resources :maintenance_bills do
          resources :payments, only: [:create, :update, :destroy, :index] do
            post 'accept', to: 'payments#accept'
          end
        end
        resources :water_bills, only: [:create, :update, :destroy, :index, :show] do
          resources :water_bill_payments, only: [:create, :update, :destroy, :index, :show] do
            post 'accept', to: 'water_bill_payments#accept'
            get 'generate_invoice_pdf', on: :member
          end
        end
      end

      get "notifications", to: "notifications#index"
      get 'get_water_bills', to: 'water_bills#get_water_bills'
      get 'get_maintenance_bills', to: 'maintenance_bills#get_maintenance_bills'
      resources :dashboards, only: [:index]
      post 'login_by_customer', to: 'users#login_by_customer'
      post 'login', to: 'users#login'
      post 'logout', to: 'users#logout'
      post 'verify_otp_and_login', to: 'users#verify_otp_and_login'
      post 'forgot_password', to: 'users#forgot_password'
      post 'reset_password', to: 'users#reset_password'
      get 'dashboard', to: 'dashboards#dashboard'
      post 'reset_password_for_customer', to: 'users#reset_password_for_customer'
      post 'forgot_password_for_customer', to: 'users#forgot_password_for_customer'
      post 'accept_user', to: 'users#accept_user'
      post 'reject_user', to: 'users#reject_user'
    end
  end
end
