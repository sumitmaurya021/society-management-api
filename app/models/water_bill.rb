class WaterBill < ApplicationRecord
  belongs_to :building
  enum payment_mode: { online: 0, cash: 1 }
end
