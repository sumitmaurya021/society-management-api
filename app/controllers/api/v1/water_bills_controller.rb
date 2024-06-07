# app/controllers/api/v1/water_bills_controller.rb
module Api
    module V1
      class WaterBillsController < ApplicationController
        before_action :doorkeeper_authorize!
        before_action :set_water_bill, only: [:update , :destroy]

        def index
          building = current_user.buildings.find(params[:building_id])
          water_bills = building.water_bills
          render json: { water_bills: water_bills, message: 'This is list of all water bills' }, status: :ok
        end

        def show
          @water_bill = WaterBill.find(params[:id])
          render json: @water_bill
        end

        def get_water_bills
          if current_user.status == "accepted" || current_user.role == "admin"
            @water_bill = WaterBill.all
            user_room_info = current_user.room.attributes.slice("room_number", "total_units", "unit_rate", "previous_unit", "updated_unit", "current_unit")
            render json: { water_bills: @water_bill, user: current_user, user_room: user_room_info }, status: :ok
          else
            render json: { error: "Only approved users can view water bills" }, status: :forbidden
          end
        end
        
        
        def create
          building = current_user.buildings.find(params[:building_id])
          water_bill = building.water_bills.new(water_bill_params)
          if water_bill.save
            render json: water_bill, status: :created
          else
            render json: { error: water_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        def update_units
          building = Building.find(params[:building_id])
          block = building.blocks.find(params[:block_id])
          floor = block.floors.find(params[:floor_id])
          rooms = floor.rooms
        
          water_bill = WaterBill.find(params[:water_bill_id])
          unit_rate = water_bill.unit_rate.to_f
        
          total_units = 0
        
          params[:water_bill][:room_units].each do |room_id, current_unit|
            room = rooms.find_by(id: room_id)
            next unless room
        
            current_unit = current_unit.to_f
            previous_unit = room.previous_unit.to_f
        
            # Calculate the units consumed
            units_consumed = current_unit * unit_rate
        
            # Update the room's total units
            room.total_units ||= 0
            room.total_units += units_consumed
        
            # Update the room's unit values
            room.update(
              unit_rate: unit_rate,
              previous_unit: current_unit, # Set current unit as previous unit for next update
              updated_unit: current_unit,
              current_unit: 0 # Reset current unit
            )
        
            total_units += room.total_units
          end
        
          render json: { message: "Units updated successfully", total_units: total_units }, status: :ok
        end
        
        


        def update
          if @water_bill.update(water_bill_params)
            render json: @water_bill, status: :ok
          else
            render json: { error: @water_bill.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
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
          params.require(:water_bill).permit(:bill_name, :unit_rate, :start_date, :end_date, :remarks, :bill_month_and_year)
        end

      end
    end
  end
  