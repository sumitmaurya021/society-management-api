class Room < ApplicationRecord
  belongs_to :floor
  belongs_to :block
  validates :room_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # attribute :floor_number, :integer
end
