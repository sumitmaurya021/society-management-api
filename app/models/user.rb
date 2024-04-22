class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :otp_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

                
  attr_accessor :otp


  def self.authenticate(email, password)
   user = User.find_for_authentication(email: email)
   user&.valid_password?(password) ? user : nil
  end

  def generate_otp
    binding.pry
    self.otp = rand(1000..9999).to_s.rjust(4, '0')
    save
  end

  def send_otp
    UserMailer.otp_email(self).deliver_now
  end


  def verify_otp(input_otp)
    otp == input_otp
  end
end
