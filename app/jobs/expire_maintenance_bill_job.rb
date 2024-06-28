class ExpireMaintenanceBillJob < ApplicationJob
  queue_as :default

  def perform(maintenance_bill_id)
    maintenance_bill = MaintenanceBill.find_by(id: maintenance_bill_id)
    return unless maintenance_bill

    if maintenance_bill.status == 'pending' && maintenance_bill.end_date < Date.current
      maintenance_bill.update(status: 'expired')
    end
  end
end
