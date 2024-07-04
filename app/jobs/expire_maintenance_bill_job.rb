class ExpireMaintenanceBillJob < ApplicationJob
  queue_as :default

  def perform(maintenance_bill_id)
    # MaintenanceBill ID se maintenance_bill dhundho
    maintenance_bill = MaintenanceBill.find_by(id: maintenance_bill_id)
    return unless maintenance_bill  # Agar maintenance_bill nahi mila toh job khatam

    # Conditions check karo maintenance bill ko expire karne ke liye
    if maintenance_bill.status == 'pending' && maintenance_bill.end_date == Date.current
      # Maintenance bill ka status update karo 'expired' karne ke liye
      maintenance_bill.update(status: 'expired')

      # Sabhi unpaid users ko retrieve karo jo is maintenance bill se judhe hain
      unpaid_users = User.joins(:payments)
                         .where(payments: { maintenance_bill_id: maintenance_bill.id, status: 'pending' })
                         .distinct

      # Har user ke liye late fee deduct karo based on owner_or_renter
      unpaid_users.each do |user|
        if user.owner_or_renter == 'owner'
          user.update(owner_amount: user.owner_amount + maintenance_bill.late_fee)
        elsif user.owner_or_renter == 'renter'
          user.update(rent_amount: user.rent_amount + maintenance_bill.late_fee)
        end
      end
    end
  end
end
