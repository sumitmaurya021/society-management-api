module Api
  module V1
    class MaintenanceBillsController < ApplicationController
      before_action :doorkeeper_authorize!
      before_action :set_maintenance_bill, only: [:update, :destroy]

      def index
        building = current_user.buildings.find(params[:building_id])
        maintenance_bills = MaintenanceBill.joins(room: { floor: :block }).where('blocks.building_id = ?', building.id)

        # Map maintenance_bills to include all details
        mapped_maintenance_bills = maintenance_bills.map do |bill|
          {
            id: bill.id,
            room_id: bill.room.id,
            building_id: building.id,
            bill_name: bill.bill_name,
            bill_month_and_year: bill.bill_month_and_year,
            owner_amount: bill.owner_amount,
            rent_amount: bill.rent_amount,
            start_date: bill.start_date,
            end_date: bill.end_date,
            remarks: bill.remarks,
            created_at: bill.created_at,
            updated_at: bill.updated_at,
            building: {
              id: building.id,
              name: building.building_name,
              address: building.building_address
            },
            block: {
              id: bill.room.floor.block.id,
              name: bill.room.floor.block.name,
              block_identifier: (bill.room.floor.block.id == building.blocks.first.id) ? 'A' : 'B' # Assuming first block is 'A', second is 'B', and so on
            },
            floor: {
              id: bill.room.floor.id,
              number: bill.room.floor.number
            },
            room: {
              id: bill.room.id,
              number: bill.room.room_number
            }
          }
        end

        render json: { maintenance_bills: mapped_maintenance_bills, message: 'This is a list of all maintenance bills with detailed information' }, status: :ok
      end

      def create
        building = current_user.buildings.find(params[:building_id])
        total_amount = params[:maintenance_bill][:total_amount].to_d
      
        # Extract parameters from maintenance_bill hash
        start_date = params[:maintenance_bill][:start_date]
        end_date = params[:maintenance_bill][:end_date]
        remarks = params[:maintenance_bill][:remarks]
        bill_name = params[:maintenance_bill][:bill_name]
        bill_month_and_year = params[:maintenance_bill][:bill_month_and_year]
      
        # Iterate over blocks
        building.blocks.each do |block|
          # Iterate over floors
          block.floors.each do |floor|
            # Iterate over rooms
            floor.rooms.each do |room|
              # Calculate amounts for owner and renter
              owner_amount = total_amount * 0.3 / floor.rooms.count
              rent_amount = total_amount * 0.7 / floor.rooms.count
      
              # Create maintenance bill for each room
              MaintenanceBill.create!(
                start_date: start_date,
                end_date: end_date,
                remarks: remarks,
                room_id: room.id,
                building_id: building.id, 
                bill_name: bill_name,
                bill_month_and_year: bill_month_and_year,
                owner_amount: owner_amount,
                rent_amount: rent_amount
              )
            end
          end
        end

        render json: { message: 'Maintenance bills generated successfully' }, status: :ok
      end

      def update
        @maintenance_bill.update(maintenance_bill_params)
        render json: { message: 'Maintenance bill updated successfully' }, status: :ok
      end

      def destroy
        @maintenance_bill.destroy
        render json: { message: 'Maintenance bill deleted successfully' }, status: :ok
      end

      private

      def set_maintenance_bill
        @maintenance_bill = current_user.buildings.find(params[:building_id]).maintenance_bills.find(params[:id])
      end

      def maintenance_bill_params
        params.require(:maintenance_bill).permit(:bill_name, :owner_amount, :rent_amount, :bill_month_and_year, :start_date, :end_date, :remarks)
      end
    end
  end
end
