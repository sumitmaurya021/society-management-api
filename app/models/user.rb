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
  has_many :payments, dependent: :destroy
  has_many :water_bill_payments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  attr_accessor :block_name, :floor_number
  before_validation :assign_block_floor_and_room, if: :customer?

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

  def assign_block_floor_and_room
    block = Block.find_by(block_name: block_name)
    floor = block.floors.find_by(floor_number: floor_number) if block
    room = floor.rooms.find_by(room_number: room_number) if floor

    if block && floor && room
      self.block = block
      self.floor = floor
      self.room = room
    else
      errors.add(:base, "Invalid block, floor, or room details")
    end
  end


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
