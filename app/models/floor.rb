class Floor < ApplicationRecord
  belongs_to :block
  has_many :rooms, dependent: :destroy

  validates :number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
