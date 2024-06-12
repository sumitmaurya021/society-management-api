module Api
  module V1
    class WaterBillPaymentsController < ApplicationController
      skip_before_action :doorkeeper_authorize!, only: [:generate_invoice_pdf , :index]
      before_action :set_water_bill
      before_action :set_water_bill_payment, only: [:generate_invoice_pdf]

      def index
        water_bill_payments = @water_bill.water_bill_payments.includes(:user => [:block, :floor, :room])
        
        detailed_payments = water_bill_payments.map do |payment|
          {
            id: payment.id,
            month_year: payment.month_year,
            bill_name: payment.bill_name,
            block_name: payment.user.block.block_name,
            floor_number: payment.user.floor.floor_number,
            room_number: payment.user.room.room_number,
            amount: payment.amount,
            payment_method: payment.payment_method,
            user_id: payment.user_id,
            water_bill_id: payment.water_bill_id,
            status: payment.status,
            created_at: payment.created_at,
            updated_at: payment.updated_at
          }
        end
    
        render json: { water_bill_payments: detailed_payments }, status: :ok
      end

      def show
        @payment = @water_bill.water_bill_payments.find_by(id: params[:id])
        render json: { payment: @payment }, status: :ok
      end

      def create
        user_id = doorkeeper_token.resource_owner_id
        current_user = User.find(user_id)
        
        room = current_user.room
        if room.nil?
          render json: { error: "Room not found for the current user" }, status: :unprocessable_entity
          return
        end

        total_units = room.total_units || 0
        amount = total_units

        if amount <= 0
          render json: { error: "No amount due for payment" }, status: :unprocessable_entity
          return
        end

        payment = @water_bill.water_bill_payments.new(
          month_year: params[:month_year],
          bill_name: @water_bill.bill_name,
          block: room.block_id.to_s,
          floor: room.floor_id,
          room_number: room.room_number,
          amount: amount,
          payment_method: params[:payment_method],
          user_id: current_user.id,
          status: "pending"
        )

        if payment.save
          room.total_units -= total_units
          room.save

          render json: { message: "Payment created successfully", payment: payment, amount_due: amount }, status: :ok
        else
          Rails.logger.error "WaterBillPayment save error: #{payment.errors.full_messages.join(', ')}"
          render json: { error: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def user
        @user = User.find_by(id: params[:user_id])
        render json: { user: @user, message: "This is the user" }, status: :ok
      end

      def accept
        payment_id = params[:payment_id]
        @payment = @water_bill.water_bill_payments.find_by(id: payment_id)

        if @payment.nil?
          render json: { error: "WaterBillPayment not found" }, status: :not_found
          return
        end

        if @payment.status != "pending"
          render json: { error: "Payment status is not pending" }, status: :unprocessable_entity
          return
        end

        if @payment.update(status: "Paid")
          
          PaymentMailer.payment_accepted_email(@payment).deliver_now
          render json: { message: "Payment accepted successfully", payment: @payment }, status: :ok
        else
          render json: { error: @payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def generate_invoice_pdf
        respond_to do |format|
          format.pdf do
            pdf = Prawn::Document.new
            pdf.text "Water Bill Payment Invoice", size: 30, style: :bold
            pdf.move_down 20
            pdf.text "Payment ID: #{@water_bill_payment.id}", size: 15
            pdf.text "Month/Year: #{@water_bill_payment.month_year}", size: 15
            pdf.text "Bill Name: #{@water_bill_payment.bill_name}", size: 15
            pdf.text "Block: #{@water_bill_payment.user.block.block_name}", size: 15
            pdf.text "Floor: #{@water_bill_payment.user.floor.floor_number}", size: 15
            pdf.text "Room: #{@water_bill_payment.user.room.room_number}", size: 15
            pdf.text "Amount: #{@water_bill_payment.amount}", size: 15
            pdf.text "Payment Method: #{@water_bill_payment.payment_method}", size: 15
            pdf.text "Status: #{@water_bill_payment.status}", size: 15
            pdf.text "Created At: #{@water_bill_payment.created_at}", size: 15
            pdf.text "Updated At: #{@water_bill_payment.updated_at}", size: 15

            send_data pdf.render, filename: "invoice_#{@water_bill_payment.id}.pdf", type: 'application/pdf', disposition: 'inline'
          end
        end
      end
      

      private

      def set_water_bill
        @water_bill = WaterBill.find_by(id: params[:water_bill_id])
        render json: { error: "Water bill not found" }, status: :not_found unless @water_bill
      end

      def set_water_bill_payment        
        @water_bill_payment = WaterBillPayment.find_by(id: params[:id])
        render json: { error: "WaterBillPayment not found" }, status: :not_found unless @water_bill_payment
      end
    end
  end
end
