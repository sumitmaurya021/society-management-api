module Api
  module V1
    class ShopsController < ApplicationController
      before_action :doorkeeper_authorize!
      before_action :set_block
      before_action :set_floor

      def index
        shops = @floor.shops
        render json: shops, status: :ok
      end

      def show
        shop = @floor.shops.find(params[:id])
        render json: shop, status: :ok
      end

      def create
        shop = @floor.shops.new(shop_params)
        shop.block = @block

        if shop.save
          render json: shop, status: :created
        else
          render json: { error: shop.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      private

      def set_block
        @block = Block.find(params[:block_id])
      end

      def set_floor
        @floor = @block.floors.find(params[:floor_id])
      end

      def shop_params
        params.require(:shop).permit(:shop_name)
      end
    end
  end
end
