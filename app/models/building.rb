class Building < ApplicationRecord
  belongs_to :user
  has_many :blocks, dependent: :destroy

  attr_accessor :total_blocks
  attr_accessor :ground_floor
  attr_accessor :number_of_floors
  attr_accessor :number_of_rooms_per_floor
  attr_accessor :starting_room_number

  has_many :maintenance_bills, dependent: :destroy
  has_many :water_bills, dependent: :destroy
end
