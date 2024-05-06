class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { customer: 0, admin: 1 }
  enum owner_or_renter: { renter: 0, owner: 1 }

  belongs_to :block, optional: true
  belongs_to :floor, optional: true
  belongs_to :room, optional: true

  validates :name, presence: true
  validates :mobile_number, presence: true, if: :customer?
  validates :email, presence: true, if: :admin?
  validates :block_id, :floor_id, :room_id, :status, presence: true, if: :customer?

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

  scope :admins, -> { where(role: 'admin') }
  scope :regular, -> { where(role: 'customer') }

  private

  # Generate OTP
  def generate_otp
    rand(1000..9999).to_s.rjust(4, '0')
  end

  def customer?
    role == 'customer'
  end

  def admin?
    role == 'admin'
  end
  
end
