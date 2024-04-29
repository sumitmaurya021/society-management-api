class Building < ApplicationRecord
  belongs_to :user
  has_many :blocks
  accepts_nested_attributes_for :blocks

  attr_accessor :total_blocks
  attr_accessor :ground_floor
  attr_accessor :number_of_floors
  attribute :number_of_rooms_per_floor, :integer

  has_many :maintenance_bills, dependent: :destroy
  has_many :water_bills, dependent: :destroy
end
