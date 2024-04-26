# app/controllers/api/v1/water_bills_controller.rb
module Api
    module V1
      class WaterBillsController < ApplicationController
        before_action :doorkeeper_authorize!
        before_action :set_water_bill, only: [:update]
        
        def create
          building = current_user.buildings.find(params[:building_id])
          water_bill = building.water_bills.new(water_bill_params)
          if water_bill.save
            render json: water_bill, status: :created
          else
            render json: { error: water_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        def update
          if @water_bill.update(water_bill_params)
            render json: @water_bill, status: :ok
          else
            render json: { error: @water_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end
        
  
        private

        def set_water_bill
          @water_bill = current_user.buildings.find(params[:building_id]).water_bills.find(params[:id])
        end
  
        def water_bill_params
          params.require(:water_bill).permit(:your_name, :name, :amount, :start_date, :end_date, :remarks)
        end
      end
    end
  end
  