# app/controllers/api/v1/payments_controller.rb
module Api
    module V1
      class PaymentsController < ApplicationController
        before_action :doorkeeper_authorize! 
        before_action :set_building
        before_action :set_maintenance_bill
        before_action :set_payment, only: [:update, :destroy, :accept]

        def index
          @payments = @maintenance_bill.payments
          render json: { payments: @payments, message: 'This is list of all payments' }, status: :ok
        end

        def create
          payment = @maintenance_bill.payments.new(payment_params)
          payment.status = 'pending'
        
          # Extract user-related attributes from current_user
          payment.block = current_user.block_id
          payment.floor = current_user.floor_id
          payment.room_number = current_user.room_number
          payment.user_id = current_user.id
        
          if payment.save
            render json: payment, status: :created
          else
            render json: { error: payment.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def accept
          if current_user.role == "admin"
            if @payment
              if @payment.update(status: "paid")
                PaymentMailer.payment_success_email(@payment.user).deliver_now
                render json: @payment, status: :ok
              else
                render json: { error: @payment.errors.full_messages }, status: :unprocessable_entity
              end
            else
              render json: { error: "Payment not found" }, status: :not_found
            end
          else
            render json: { error: "Only admin can accept payments" }, status: :forbidden
          end
        end

  
        def update
          if @payment.update(payment_params)
            render json: @payment, status: :ok
          else
            render json: { error: @payment.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        def destroy
          @payment.destroy
          render json: { message: 'Payment deleted successfully' }, status: :ok
        end
  
        private
  
        def set_building
          @building = Building.find_by(id: params[:building_id])
          render json: { error: "Building not found" }, status: :not_found unless @building
        end
  
        def set_maintenance_bill
          return unless @building
  
          @maintenance_bill = @building.maintenance_bills.find_by(id: params[:maintenance_bill_id])
          render json: { error: "Maintenance bill not found" }, status: :not_found unless @maintenance_bill
        end
  
        def set_payment
          return unless @maintenance_bill
  
          @payment = @maintenance_bill.payments.find_by(id: params[:payment_id])
          render json: { error: "Payment not found" }, status: :not_found unless @payment
        end
  
        def payment_params
          permitted_params = params.require(:payment).permit(:month_year, :bill_name, :block, :floor, :room_number, :amount, :payment_method)
        
          # Permit maintenance_bill_id and water_bill_id only if they are present in the request
          permitted_params[:maintenance_bill_id] = params[:payment][:maintenance_bill_id] if params[:payment][:maintenance_bill_id].present?
          permitted_params[:water_bill_id] = params[:payment][:water_bill_id] if params[:payment][:water_bill_id].present?
        
          permitted_params
        end
      end
    end
  end
  