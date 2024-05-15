class WaterBill < ApplicationRecord
  belongs_to :building
  has_many :payments
end
