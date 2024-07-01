module Api
    module V1
      class PaymentsController < ApplicationController
        before_action :doorkeeper_authorize!, only: [:index]
        before_action :set_building
        before_action :set_maintenance_bill
        before_action :set_payment, only: [:update, :destroy, :accept]

        def generate_invoice_pdf
          @payment = @maintenance_bill.payments.find_by(id: params[:id])
          respond_to do |format|
            format.pdf do
              pdf = Prawn::Document.new
              pdf.text "Maintenance Bill Payment Invoice", size: 30, style: :bold
              pdf.move_down 20
              pdf.text "Payment ID: #{@payment.id}", size: 15
              pdf.text "Month/Year: #{@payment.month_year}", size: 15
              pdf.text "Bill Name: #{@payment.bill_name}", size: 15
              pdf.text "Block: #{@payment.user.block.block_name}", size: 15
              pdf.text "Floor: #{@payment.user.floor.floor_number}", size: 15
              pdf.text "Room: #{@payment.user.room.room_number}", size: 15
              pdf.text "Amount: #{@payment.amount}", size: 15
              pdf.text "Payment Method: #{@payment.payment_method}", size: 15
              pdf.text "Status: #{@payment.status}", size: 15
              pdf.text "Created At: #{@payment.created_at}", size: 15
              pdf.text "Updated At: #{@payment.updated_at}", size: 15

              send_data pdf.render, filename: "invoice_#{@payment.id}.pdf", type: 'application/pdf', disposition: 'inline'
            end
          end
        end


        def index
          maintenance_bill_payments = @maintenance_bill.payments.includes(:user => [:block, :floor, :room])

          detailed_payments = maintenance_bill_payments.map do |payment|
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
              maintenance_bill_id: payment.maintenance_bill_id,
              status: payment.status,
              created_at: payment.created_at,
              updated_at: payment.updated_at
            }
          end

          render json: { maintenance_bill_payments: detailed_payments }, status: :ok
        end

        def show
          @payment = @maintenance_bill.payments.find_by(id: params[:id])
          if @payment
            render json: @payment, status: :ok
          else
            render json: { error: "Payment not found" }, status: :not_found
          end
        end


        def create
          if @maintenance_bill.expired?
            render json: { error: "Cannot create payment for an expired maintenance bill" }, status: :forbidden
            return
          end

          payment = @maintenance_bill.payments.new(payment_params)
          payment.status = 'pending'

          payment.block = current_user.block_id
          payment.floor = current_user.floor_id
          payment.room_number = current_user.room_number
          payment.user_id = current_user.id

          if payment.save
            render json: payment, status: :created
          else
            render json: { error: payment.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def accept
          if current_user.role == "admin"
            if @payment
              if @payment.update(status: "paid")
                PaymentMailer.payment_success_email(@payment.user).deliver_now
                render json: @payment, status: :ok
              else
                render json: { error: @payment.errors.full_messages }, status: :unprocessable_entity
              end
            else
              render json: { error: "Payment not found" }, status: :not_found
            end
          else
            render json: { error: "Only admin can accept payments" }, status: :forbidden
          end
        end


        def update
          if @maintenance_bill.expired?
            render json: { error: "Cannot update payment for an expired maintenance bill" }, status: :forbidden
            return
          end

          if @payment.update(payment_params)
            render json: @payment, status: :ok
          else
            render json: { error: @payment.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @payment.destroy
          render json: { message: 'Payment deleted successfully' }, status: :ok
        end

        private

        def set_building
          @building = Building.find_by(id: params[:building_id])
          render json: { error: "Building not found" }, status: :not_found unless @building
        end

        def set_maintenance_bill
          return unless @building

          @maintenance_bill = @building.maintenance_bills.find_by(id: params[:maintenance_bill_id])
          render json: { error: "Maintenance bill not found" }, status: :not_found unless @maintenance_bill
        end

        def set_payment

          return unless @maintenance_bill

          @payment = @maintenance_bill.payments.find_by(id: params[:payment_id])
          render json: { error: "Payment not found" }, status: :not_found unless @payment
        end

        def payment_params
          permitted_params = params.require(:payment).permit(:month_year, :bill_name, :block, :floor, :room_number, :amount, :payment_method)

          # Permit maintenance_bill_id and water_bill_id only if they are present in the request
          permitted_params[:maintenance_bill_id] = params[:payment][:maintenance_bill_id] if params[:payment][:maintenance_bill_id].present?
          permitted_params[:water_bill_id] = params[:payment][:water_bill_id] if params[:payment][:water_bill_id].present?

          permitted_params
        end
      end
    end
  end
