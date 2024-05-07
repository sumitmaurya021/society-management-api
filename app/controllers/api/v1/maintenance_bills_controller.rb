# app/controllers/api/v1/maintenance_bills_controller.rb
module Api
    module V1
      class MaintenanceBillsController < ApplicationController
        before_action :doorkeeper_authorize!
        before_action :set_maintenance_bill, only: [:update , :destroy]

        def index
          building = current_user.buildings.find(params[:building_id])
          maintenance_bills = building.maintenance_bills
          render json: maintenance_bills
        end
        
        def create
          building = current_user.buildings.find(params[:building_id])
          maintenance_bill = building.maintenance_bills.new(maintenance_bill_params)
          if maintenance_bill.save
            render json: maintenance_bill, status: :created
          else
            render json: { error: maintenance_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        def update
          if @maintenance_bill.update(maintenance_bill_params)
            render json: @maintenance_bill, status: :ok
          else
            render json: { error: @maintenance_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        def destroy
          @maintenance_bill.destroy
          render json: { message: 'Maintenance bill deleted successfully' }, status: :ok
        end

        private

        def set_maintenance_bill
          @maintenance_bill = current_user.buildings.find(params[:building_id]).maintenance_bills.find(params[:id])
        end

        def maintenance_bill_params
          params.require(:maintenance_bill).permit(:bill_name, :owner_amount, :rent_amount, :bill_month_and_year, :start_date, :end_date, :remarks, :payment_mode)
        end
      end
    end
  end
  