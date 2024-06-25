# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum role: { customer: 0, admin: 1, shop: 2 }
  enum owner_or_renter: { renter: 0, owner: 1 }

  belongs_to :block, optional: true
  belongs_to :floor, optional: true
  belongs_to :room, optional: true

  has_many :buildings, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :water_bill_payments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :vehicles, dependent: :destroy

  attr_accessor :block_name, :floor_number, :room_number, :skip_block_floor_assignment

  validate :validate_block_floor_room, unless: -> { role == 'admin' }
  before_validation :assign_block_floor_and_room, unless: -> { role == 'admin' || skip_block_floor_assignment }

  validates :name, presence: true
  validates :email, presence: true
  validates :mobile_number, presence: true, if: :customer_or_shop?
  validates :block_name, :floor_number, presence: true, if: :residential_or_shop?
  validates :room_number, presence: true, if: :residential_user?

  scope :admins, -> { where(role: 'admin') }
  scope :regular, -> { where(role: 'customer') }
  scope :shops, -> { where(role: 'shop') }

  def self.authenticate(email, password)
    user = User.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end

  def send_reset_password_instructions
    otp = generate_otp
    update(reset_password_token: otp, reset_password_sent_at: Time.now)
    UserMailer.with(user: self, otp: otp).reset_password_email.deliver_now
  end

  private

  def validate_block_floor_room
    if block_name.blank?
      errors.add(:block_name, "can't be blank")
    end

    if floor_number.blank?
      errors.add(:floor_number, "can't be blank")
    end

    if room_number.blank?
      errors.add(:room_number, "can't be blank")
    end
  end

  def residential_user?
    customer?
  end

  def residential_or_shop?
    customer? || shop?
  end

  def customer_or_shop?
    customer? || shop?
  end

  def assign_block_floor_and_room
    block = Block.find_by(block_name: block_name)
    floor = block.floors.find_by(floor_number: floor_number) if block

    if block && floor
      self.block = block
      self.floor = floor
      self.room = floor.rooms.find_by(room_number: room_number) if floor
    else
      errors.add(:base, "Invalid block, floor, or room details")
    end
  end

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
