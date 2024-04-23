# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
    def otp_email(user)
      @user = user
      mail(to: @user.email, subject: 'Your OTP for Login')
    end
  end
  