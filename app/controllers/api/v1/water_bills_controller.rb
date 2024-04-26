# app/controllers/api/v1/water_bills_controller.rb
module Api
    module V1
      class WaterBillsController < ApplicationController
        before_action :doorkeeper_authorize!
        
        def create
          building = current_user.buildings.find(params[:building_id])
          water_bill = building.water_bills.new(water_bill_params)
          if water_bill.save
            render json: water_bill, status: :created
          else
            render json: { error: water_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end
  
        private
  
        def water_bill_params
          params.require(:water_bill).permit(:your_name, :name, :amount, :start_date, :end_date, :remarks)
        end
      end
    end
  end
  