module Api
    module V1
      class WaterBillPaymentsController < ApplicationController
        skip_before_action :doorkeeper_authorize!, only: [:generate_invoice_pdf]
        before_action :set_water_bill
        before_action :set_water_bill_payment, only: [:generate_invoice_pdf]
  
        def index
          water_bill_payments = @water_bill.water_bill_payments
          render json: { water_bill_payments: water_bill_payments }, status: :ok
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
            render json: { error: payment.errors.full_messages }, status: :unprocessable_entity
          end
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

          pdf = WickedPdf.new.pdf_from_string(
            render_to_string(
              template: 'invoices/water_pdf',
              layout: 'pdf', 
              locals: { payment: @water_bill_payment },
              dpi: 300
            ),
          )

          send_data pdf, filename: 'Water_Analysis_Invoice.pdf', type: 'application/pdf'
        end
        
        
  
        private
  
        def set_water_bill
          @water_bill = WaterBill.find_by(id: params[:water_bill_id])
          render json: { error: "Water bill not found" }, status: :not_found unless @water_bill
        end

        def set_water_bill_payment
          @water_bill_payment = WaterBillPayment.find_by(id: params[:water_bill_id])
          render json: { error: "WaterBillPayment not found" }, status: :not_found unless @water_bill_payment
        end


      end
    end
  end
  