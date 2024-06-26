class Block < ApplicationRecord
  belongs_to :building
  has_many :floors, dependent: :destroy
  validates :block_name, presence: true
end
