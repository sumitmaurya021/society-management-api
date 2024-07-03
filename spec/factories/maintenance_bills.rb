FactoryBot.define do
  factory :maintenance_bill do
    building
    late_fee { 100.0 }
    end_date { Date.current }
    bill_name { "Bill #{building.name}" }
    bill_month_and_year { Date.current.strftime("%B %Y") }
    owner_amount { 200.0 }
    rent_amount { 300.0 }
    start_date { Date.current - 1.month }
    remarks { "Remarks for #{building.name}" }
    status { "pending" }
  end
end
