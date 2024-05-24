class WaterBillPayment < ApplicationRecord
  belongs_to :user
  belongs_to :water_bill

  enum status: { pending: 0, Paid: 1 }

  validates :month_year, :bill_name, :block, :floor, :room_number, :amount, :payment_method, presence: true
end
