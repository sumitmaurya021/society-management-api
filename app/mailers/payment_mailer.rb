class PaymentMailer < ApplicationMailer
    def payment_success_email(user)
        @user = user
        mail(to: @user.email, subject: 'Payment Success Notification')
      end
end
