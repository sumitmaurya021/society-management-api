module Api
    module V1
        class BlocksController < ApplicationController
            before_action :doorkeeper_authorize!

            def index
                building = Building.find(params[:building_id])
                blocks = building.blocks
                render json: blocks
            end

            def show
                building = Building.find(params[:building_id])
                block = building.blocks.find(params[:id])
                render json: block
            end
        end
    end
end
