# spec/jobs/expire_maintenance_bill_job_spec.rb
require 'rails_helper'

RSpec.describe ExpireMaintenanceBillJob, type: :job do
  let!(:user_owner) { create(:user, owner_or_renter: :owner, owner_amount: 0.0) }
  let!(:user_renter) { create(:user, owner_or_renter: :renter, rent_amount: 0.0) }
  let!(:maintenance_bill) { create(:maintenance_bill) }
  let!(:payment_owner) { create(:payment, user: user_owner, maintenance_bill: maintenance_bill, payment_status: :pending) }
  let!(:payment_renter) { create(:payment, user: user_renter, maintenance_bill: maintenance_bill, payment_status: :pending) }

  it 'expires the maintenance bill and adds late fees to users' do
    expect {
      ExpireMaintenanceBillJob.perform_now(maintenance_bill.id)
    }.to change { maintenance_bill.reload.status }.from('pending').to('expired')
      .and change { user_owner.reload.owner_amount }.from(0.0).to(maintenance_bill.late_fee)
      .and change { user_renter.reload.rent_amount }.from(0.0).to(maintenance_bill.late_fee)
  end

  it 'does not apply late fees to users who have paid' do
    payment_owner.update(payment_status: :paid)

    expect {
      ExpireMaintenanceBillJob.perform_now(maintenance_bill.id)
    }.to change { maintenance_bill.reload.status }.from('pending').to('expired')
      .and not_change { user_owner.reload.owner_amount }
      .and change { user_renter.reload.rent_amount }.from(0.0).to(maintenance_bill.late_fee)
  end
end
