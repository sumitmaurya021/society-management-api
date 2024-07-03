FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    email { 'john.doe@example.com' }
    password { 'password' }
    role { :customer }
    owner_or_renter { :renter }
    mobile_number { '1234567890' }
    gender { :male }
    status { :active }
    room_number { 1 }
    room_id { 1 }
    block_id { 1 }
    floor_id { 1 }
    rent_amount { 100.0 }
    owner_amount { 200.0 }
  end
end
