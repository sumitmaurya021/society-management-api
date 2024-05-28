class PaymentMailer < ApplicationMailer
    def payment_success_email(user)
        @user = user
        mail(to: @user.email, subject: 'Payment Success Notification')
      end

      def payment_accepted_email(payment)
        @payment = payment
        @user = @payment.user
    
        # Generate the PDF from the template
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string(
            template: 'water_bill_payments/water_pdf',
            layout: 'pdf', # Assuming you have a 'pdf.html.erb' layout for styling
            locals: { payment: @payment }
          ),
          page_size: 'A4'
        )
    
        # Attach the generated PDF to the email
        attachments['Water_Analysis_Invoice.pdf'] = { mime_type: 'application/pdf', content: pdf }
    
        mail(to: @user.email, subject: 'Payment Accepted')
      end
end
