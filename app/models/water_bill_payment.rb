class WaterBillPayment < ApplicationRecord
  belongs_to :user
  belongs_to :water_bill

  enum status: { pending: 0, Paid: 1 }

  validates :month_year, :bill_name, :block, :floor, :room_number, :amount, :payment_method, presence: true
  validates :amount, numericality: { greater_then_or_equal_to: 0 }

  private

  def greater_then_or_equal_to
    if amount < 0
      errors.add(:amount, "must be greater than or equal to 0")
    end
  end
  
end
