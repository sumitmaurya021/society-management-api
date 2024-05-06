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

  def reset_password_email_for_customer
    @user = params[:user]
    @otp = params[:otp]
    mail(to: @user.email, subject: 'Password Reset OTP for Customer')
  end

  def accept_user_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your account has been accepted')
  end

  def reject_user_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your account has been rejected')
  end

  
end
