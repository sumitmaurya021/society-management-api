# app/controllers/api/v1/vehicles_controller.rb
module Api
    module V1
      class VehiclesController < ApplicationController
        before_action :doorkeeper_authorize!
  
        def index
          @room = Room.find(params[:room_id])
          @vehicles = @room.vehicles.map do |vehicle|
            {
              id: vehicle.id,
              total_no_of_two_wheeler: vehicle.total_no_of_two_wheeler,
              total_no_of_four_wheeler: vehicle.total_no_of_four_wheeler,
              two_wheeler_numbers: vehicle.two_wheeler_numbers,
              four_wheeler_numbers: vehicle.four_wheeler_numbers,
              room_id: vehicle.room_id,
              user_id: vehicle.user_id,
              name: vehicle.user.name,
              email: vehicle.user.email,
              mobile_number: vehicle.user.mobile_number,
              floor_number: vehicle.user.floor.floor_number,
              block_name: vehicle.user.block.block_name,
              room_number: vehicle.user.room.room_number,
              created_at: vehicle.created_at,
              updated_at: vehicle.updated_at
            }
          end
  
          render json: { vehicles: @vehicles, message: 'Room Vehicles' }, status: :ok
        end
  
        def show    
          @room = Room.find(params[:room_id])
          @vehicle = @room.vehicles.find(params[:id])
          render json: { vehicle: @vehicle, message: 'Room Vehicle' }, status: :ok
        end
  
        def create
          @room = Room.find(params[:room_id])
          @vehicle = @room.vehicles.build(vehicle_params)
          @vehicle.user_id = current_user.id
          
          if @vehicle.save
            render json: { 
              id: @vehicle.id,
              total_no_of_two_wheeler: @vehicle.total_no_of_two_wheeler,
              total_no_of_four_wheeler: @vehicle.total_no_of_four_wheeler,
              two_wheeler_numbers: @vehicle.two_wheeler_numbers,
              four_wheeler_numbers: @vehicle.four_wheeler_numbers,
              room_id: @vehicle.room_id,
              user_id: @vehicle.user_id,
              created_at: @vehicle.created_at,
              updated_at: @vehicle.updated_at
            }, status: :created
          else
            render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        private
  
        def vehicle_params
          params.require(:vehicle).permit(
            :total_no_of_two_wheeler,
            :total_no_of_four_wheeler,
            two_wheeler_numbers: [],
            four_wheeler_numbers: []
          )
        end
      end
    end
  end
  