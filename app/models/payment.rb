class Payment < ApplicationRecord
    belongs_to :user
    belongs_to :maintenance_bill, optional: true
    belongs_to :water_bill, optional: true

    
    enum status: { pending: 0, paid: 1 }
end
