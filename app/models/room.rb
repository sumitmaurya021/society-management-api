class Room < ApplicationRecord
  belongs_to :floor
  belongs_to :block
  has_many :users
  has_many :maintenance_bills, dependent: :destroy
  has_many :water_bills, dependent: :destroy
  validates :room_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # attribute :floor_number, :integer
end