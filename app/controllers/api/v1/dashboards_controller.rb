module Api
    module V1
        class DashboardsController < ApplicationController
            before_action :doorkeeper_authorize!

            def dashboard
                @user = current_user
                @building = @user.buildings
                @block = Block.all
                @floor = Floor.all
                @room = Room.all
                render json: { user: @user, building: @building, block: @block, floor: @floor, room: @room }, status: :ok
            end
        end
    end
end