class Payment < ApplicationRecord
    belongs_to :user
    belongs_to :maintenance_bill, optional: true


    enum status: { pending: 0, paid: 1, failed: 2 }
end
