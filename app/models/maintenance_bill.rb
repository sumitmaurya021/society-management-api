class MaintenanceBill < ApplicationRecord
  belongs_to :building

  validates :your_name, presence: true
  validates :name, presence: true
  validates :amount, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :remarks, presence: true

end
