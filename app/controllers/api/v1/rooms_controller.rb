module Api
    module V1
        class RoomsController < ApplicationController
            before_action :doorkeeper_authorize!

                def index
                    building = Building.find(params[:building_id])
                    block = building.blocks.find(params[:block_id])
                    floor = block.floors.find(params[:floor_id])
                    rooms = floor.rooms
                    @rooms = rooms.map do |room|
                      {
                        id: room.id,
                        room_number: room.room_number,
                        floor_id: room.floor_id,
                        block_id: room.block_id,
                        created_at: room.created_at,
                        updated_at: room.updated_at,
                        total_units: room.total_units,
                        unit_rate: room.unit_rate,
                        previous_unit: room.previous_unit,
                        updated_unit: room.updated_unit,
                        current_unit: room.current_unit,
                        user_name: room.users.pluck(:name),
                        user_email: room.users.pluck(:email),
                        user_role: room.users.pluck(:role),
                        user_mobile: room.users.pluck(:mobile_number),
                        user_status: room.users.pluck(:status),
                        user_gender: room.users.pluck(:gender)
                      }
                    end

                    if rooms.present?
                      render json: @rooms, status: :ok
                    else
                      render json: { message: 'No rooms found for the specified floor' }, status: :ok
                    end
                  rescue ActiveRecord::RecordNotFound => e
                    render json: { error: e.message }, status: :not_found
            end

            def show
                @room = Room.find(params[:id])
                render json: { room: @room, message: 'Room Find With Specific Id' }, status: :ok
            end
        end
    end
end
