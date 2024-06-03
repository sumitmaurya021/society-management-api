class WaterBill < ApplicationRecord
  belongs_to :building
  has_many :water_bill_payments, dependent: :destroy
end
