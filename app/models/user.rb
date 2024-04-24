class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
                

  has_many :buildings, dependent: :destroy
  def self.authenticate(email, password)
   user = User.find_for_authentication(email: email)
   user&.valid_password?(password) ? user : nil
  end

  def send_reset_password_instructions
    otp = generate_otp
    update(reset_password_token: otp, reset_password_sent_at: Time.now)
    UserMailer.with(user: self, otp: otp).reset_password_email.deliver_now
  end

end
