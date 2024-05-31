class Block < ApplicationRecord
  belongs_to :building
  has_many :floors, dependent: :destroy
  has_many :rooms, through: :floors, dependent: :destroy
  validates :name, presence: true

  attr_accessor :number_of_rooms_per_floor
end
