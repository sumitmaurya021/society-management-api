class Block < ApplicationRecord
  belongs_to :building
  has_many :floors, dependent: :destroy
  validates :name, presence: true
end
