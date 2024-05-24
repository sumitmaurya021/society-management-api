class Notification < ApplicationRecord
  belongs_to :user
  

  after_initialize :set_defaults

  private

  def set_defaults
    self.read ||= false
  end
end
