module Api
    module V1
      class BuildingsController < ApplicationController
        before_action :doorkeeper_authorize!
  
        # POST /api/v1/buildings
        def create
          building = current_user.buildings.new(building_params)
          if building.save
            generate_blocks(building)
            render json: building, status: :created
          else
            render json: { error: building.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end
  
        private
  
        def building_params
          params.require(:building).permit(:building_name, :building_address, :total_blocks, :number_of_floors, :ground_floor, :number_of_rooms_per_floor)
        end
  
        def generate_blocks(building)
          building.total_blocks.times do |block_number|
            block_name = ("A".ord + block_number).chr
            block = building.blocks.create(name: block_name)
            generate_floors(block, building.number_of_floors, building.number_of_rooms_per_floor)
          end
        end
  
        def generate_floors(block, number_of_floors, number_of_rooms_per_floor)
          start_floor = block.building.ground_floor ? 0 : 1
          (start_floor..number_of_floors).each do |floor_number|
            floor = block.floors.create(number: floor_number)
            generate_rooms(floor, number_of_rooms_per_floor)
          end
        end
        
        def generate_rooms(floor, number_of_rooms_per_floor)
          return unless number_of_rooms_per_floor
          number_of_rooms_per_floor.times do |room_number|
            room = floor.rooms.create(room_number: room_number + 1)
            room.update(block_id: floor.block_id, floor_id: floor.id)
          end
        end
      end
    end
  end
  