class MaintenanceBill < ApplicationRecord
  belongs_to :building
  has_many :payments

  def payment_successful?
    payments.exists?(payment_status: "payment_successful")
  end

  
end
