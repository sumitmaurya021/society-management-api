# app/controllers/api/v1/maintenance_bills_controller.rb
module Api
    module V1
      class MaintenanceBillsController < ApplicationController
        before_action :doorkeeper_authorize!
        
        def create
          building = current_user.buildings.find(params[:building_id])
          maintenance_bill = building.maintenance_bills.new(maintenance_bill_params)
          if maintenance_bill.save
            render json: maintenance_bill, status: :created
          else
            render json: { error: maintenance_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end
  
        private
  
        def maintenance_bill_params
          params.require(:maintenance_bill).permit(:your_name, :name, :amount, :start_date, :end_date, :remarks)
        end
      end
    end
  end
  