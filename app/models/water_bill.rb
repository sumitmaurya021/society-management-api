class WaterBill < ApplicationRecord
  belongs_to :building
  has_many :water_bill_payments, dependent: :destroy

  validates :bill_name, :unit_rate, :start_date, :end_date, :bill_month_and_year, presence: true
  validates :unit_rate, numericality: { greater_then_or_equal_to: 0 }

  private

  def greater_then_or_equal_to
    if unit_rate < 0
      errors.add(:unit_rate, "must be greater than or equal to 0")
    end
  end
  
end
