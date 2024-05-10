class Payment < ApplicationRecord
    belongs_to :maintenance_bill
    enum status: { pending: 0, paid: 1 }
end
