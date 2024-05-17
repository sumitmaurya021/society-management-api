module Api
    module V1
        class FloorsController < ApplicationController
            before_action :doorkeeper_authorize!

            def index
                building = Building.find(params[:building_id])
                block = building.blocks.find(params[:block_id])
                floor = block.floors
                render json: floor
            end

            def show
                building = Building.find(params[:building_id])
                block = building.blocks.find(params[:block_id])
                floor = block.floors.find(params[:id])
                render json: floor
            end
        end
    end
end
