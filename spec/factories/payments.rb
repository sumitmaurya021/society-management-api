FactoryBot.define do
  factory :payment do
    user
    maintenance_bill
    payment_status { :pending }
    amount { 100.0 }
    payment_method { :cash }
  end
end
