class Shop < ApplicationRecord
  belongs_to :block
  belongs_to :floor

  validates :shop_name, presence: true
end
