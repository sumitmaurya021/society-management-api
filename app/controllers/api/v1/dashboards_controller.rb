# app/controllers/api/v1/dashboards_controller.rb
module Api
  module V1
    class DashboardsController < ApplicationController
      before_action :doorkeeper_authorize!

      def index
        users = User.all.includes(:buildings)
        admin_users = users.admins
        regular_users = users.regular
        buildings = Building.all.includes(blocks: { floors: :rooms })

        dashboard_info = {
          users_count: users.count,
          admin_users_count: admin_users.count,
          admin_users: admin_users.map { |user| user_info(user) },
          regular_users_count: regular_users.count,
          regular_users: regular_users.map { |user| user_info(user) },
          buildings_count: buildings.count,
          buildings: buildings.map { |building| building_info(building) }
        }

        render json: dashboard_info, status: :ok
      end

      def maintenance_bill_summary
        buildings = Building.includes(blocks: { floors: :rooms })

        summary = buildings.map do |building|
          total_owner_amount = 0
          total_rent_amount = 0
          total_payments_received = 0

          building.blocks.each do |block|
            block.floors.each do |floor|
              total_owner_amount += floor.rooms.count * building.maintenance_bills.sum(:owner_amount)
              total_rent_amount += floor.rooms.count * building.maintenance_bills.sum(:rent_amount)
            end
          end

          total_amount = total_owner_amount + total_rent_amount
          total_payments_received = building.maintenance_bills.joins(:payments).where(payments: { status: :paid }).sum(:amount)
          remaining_payments = total_amount - total_payments_received

          {
            building_id: building.id,
            building_name: building.building_name,
            total_amount: total_amount,
            total_payments_received: total_payments_received,
            remaining_payments: remaining_payments
          }
        end

        render json: { maintenance_bill_summary: summary }, status: :ok
      end

      private

      def user_info(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end

      def building_info(building)
        {
          id: building.id,
          name: building.building_name,
          building_address: building.building_address,
          blocks_count: building.blocks.count,
          blocks: building.blocks.map { |block| block_info(block) }
        }
      end

      def block_info(block)
        {
          id: block.id,
          name: block.block_name,
          floors_count: block.floors.count,
          floors: block.floors.map { |floor| floor_info(floor) }
        }
      end

      def floor_info(floor)
        {
          id: floor.id,
          number: floor.floor_number,
          rooms_count: floor.rooms.count,
          rooms: floor.rooms.map { |room| room_info(room) }
        }
      end

      def room_info(room)
        {
          id: room.id,
          room_number: room.room_number,
          created_at: room.created_at,
          updated_at: room.updated_at
        }
      end
    end
  end
end
