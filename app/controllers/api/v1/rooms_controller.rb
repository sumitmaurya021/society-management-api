module Api
    module V1
        class RoomsController < ApplicationController
            before_action :doorkeeper_authorize! 

                def index
                    building = Building.find(params[:building_id])
                    block = building.blocks.find(params[:block_id])
                    floor = block.floors.find(params[:floor_id])
                    rooms = floor.rooms
                
                    if rooms.present?
                      render json: rooms, status: :ok
                    else
                      render json: { message: 'No rooms found for the specified floor' }, status: :ok
                    end
                  rescue ActiveRecord::RecordNotFound => e
                    render json: { error: e.message }, status: :not_found
            end

            def show
                @room = Room.find(params[:id])
                render json: @room, status: :ok
            end
        end
    end
end
