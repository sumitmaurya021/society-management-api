# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def otp_email
    @user = params[:user]
    @otp = params[:otp]
    mail(to: @user.email, subject: 'Your OTP for Login')
  end


  def reset_password_email
    @user = params[:user]
    @otp = params[:otp]
    mail(to: @user.email, subject: 'Password Reset OTP')
  end

  
end
