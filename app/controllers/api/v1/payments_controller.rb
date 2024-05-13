# app/controllers/api/v1/payments_controller.rb
module Api
    module V1
      class PaymentsController < ApplicationController
        before_action :doorkeeper_authorize!
        before_action :set_building
        before_action :set_maintenance_bill
        before_action :set_payment, only: [:update, :destroy, :accept]

        def index
          payment = @maintenance_bill.payments
          render json: { payments: payment, message: 'This is list of all payments' }, status: :ok
        end
  
        def create
          payment = @maintenance_bill.payments.new(payment_params)
          payment.status = 'pending'
          if payment.save
            render json: payment, status: :created
          else
            render json: { error: payment.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def accept
            binding.pry
            if @payment
              if @payment.update(status: "paid")
                render json: @payment, status: :ok
              else
                render json: { error: @payment.errors.full_messages }, status: :unprocessable_entity
              end
            else
              render json: { error: "Payment not found" }, status: :not_found
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
            @payment = @maintenance_bill.payments.find_by(id: params[:id])
          end
  
        def payment_params
          params.require(:payment).permit(:month_year, :bill_name, :block, :floor, :room_number, :amount, :payment_method, :status, :payment_id)
        end
      end
    end
  end
  