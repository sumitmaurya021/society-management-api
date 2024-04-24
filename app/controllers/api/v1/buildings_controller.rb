module Api
    module V1
      class BuildingsController < ApplicationController
        before_action :doorkeeper_authorize!
  
        # POST /api/v1/buildings
        def create
          if current_user.nil?
            render json: { error: 'User not authenticated' }, status: :unauthorized
            return
          end
          
          building = current_user.buildings.new(building_params)
          if building.save
            generate_blocks(building)
            render json: building, status: :created
          else
            render json: building.errors, status: :unprocessable_entity
          end
        end
  
        private
  
        def set_building
          if current_user.nil?
            render json: { error: 'User not authenticated' }, status: :unauthorized
            return
          end
  
          @building = current_user.buildings.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Building not found' }, status: :not_found
        end
  
        def building_params
          params.require(:building).permit(:building_name, :building_address, :total_blocks, :number_of_floors, :ground_floor, :number_of_rooms_per_floor)
        end
  
        def generate_blocks(building)
          (1..building.total_blocks).each do |block_number|
            block_name = ("A".ord + block_number - 1).chr
            block = building.blocks.create(name: block_name)
            generate_floors(block, building.ground_floor, building.number_of_floors)
          end
        end
  
        def generate_floors(block, ground_floor, number_of_floors)
          start_floor = ground_floor ? 0 : 1
          end_floor = number_of_floors
          (start_floor..end_floor).each do |floor_number|
            block.floors.create(number: floor_number)
            generate_rooms(block, floor_number)
          end
        end
        
        def generate_rooms(block, floor_number)
            binding.pry
          return unless block.building && block.building.number_of_rooms_per_floor # Ensure block and number_of_rooms_per_floor are not nil
          block.building.number_of_rooms_per_floor.times do |room_number|
            block.rooms.create(floor_number: floor_number, room_number: room_number + 1)
          end
        end
      end
    end
  end
  