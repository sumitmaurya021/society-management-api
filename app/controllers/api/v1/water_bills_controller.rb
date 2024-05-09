# app/controllers/api/v1/water_bills_controller.rb
module Api
    module V1
      class WaterBillsController < ApplicationController
        before_action :doorkeeper_authorize!
        # before_action :set_water_bill, only: [:update , :destroy]

        def index
          building = current_user.buildings.find(params[:building_id])
          water_bill = WaterBill.where(room_id: building.rooms.pluck(:id))
          render json: { water_bill: water_bill, message: 'This is list of all water bills' }, status: :ok
        end

        def create
          building = current_user.buildings.find(params[:building_id])
          total_amount = params[:water_bill][:total_amount].to_d

          # Extract parameters from water_bill hash
          start_date = params[:water_bill][:start_date]
          end_date = params[:water_bill][:end_date]
          remarks = params[:water_bill][:remarks]
          bill_name = params[:water_bill][:bill_name]
          bill_month_and_year = params[:water_bill][:bill_month_and_year]

          # Iterate over blocks
          building.blocks.each do |block|
            # Iterate over floors
            block.floors.each do |floor|
              # Iterate over rooms
              floor.rooms.each do |room|
                # Calculate amounts for owner and renter
                owner_amount = total_amount * 0.3 / floor.rooms.count
                rent_amount = total_amount * 0.7 / floor.rooms.count

                # Create water bill for each room
                WaterBill.create!(
                  start_date: start_date,
                  end_date: end_date,
                  remarks: remarks,
                  room_id: room.id,
                  building_id: building.id,
                  bill_name: bill_name,
                  bill_month_and_year: bill_month_and_year,
                  owner_amount: owner_amount,
                  rent_amount: rent_amount
                )
              end
            end
          end

          render json: { message: 'Water bills created successfully' }, status: :created
        end

        def update
          @water_bill.update(water_bill_params)
          render json: { message: 'Water bill updated successfully' }, status: :ok
        end

        def destroy
          @water_bill.destroy
          render json: { message: 'Water bill deleted successfully' }, status: :ok
        end


  
        private

        def set_water_bill
          @water_bill = current_user.buildings.find(params[:building_id]).water_bills.find(params[:id])
        end
  
        def water_bill_params
          params.require(:water_bill).permit(:bill_name, :owner_amount, :rent_amount, :start_date, :end_date, :remarks, :bill_month_and_year)
        end
      end
    end
  end
  