class MaintenanceBill < ApplicationRecord
  belongs_to :building
  has_many :payments, dependent: :destroy
  validates :late_fee, numericality: { greater_than_or_equal_to: 0 }
  after_create :schedule_expiration_maintenance_bill_job

  def payment_successful?
    payments.exists?(payment_status: "payment_successful")
  end

  private

  def schedule_expiration_maintenance_bill_job
    ExpireMaintenanceBillJob.set(wait_until: end_date.end_of_day).perform_later(id)
  end
end
