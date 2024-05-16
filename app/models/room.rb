class Room < ApplicationRecord
  belongs_to :floor
  belongs_to :block
  has_many :users
  has_many :maintenance_bills, dependent: :destroy
  has_many :water_bills, dependent: :destroy
  validates :room_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # attribute :floor_number, :integer

  def update_units
    room = Room.find(params[:room_id])  # Assuming you're updating units for a specific room
    # Assuming the 'total_units' method should be called on the room object
    room.total_units = params[:total_units]  

    if room.save
      render json: { message: "Units updated successfully" }, status: :ok
    else
      render json: { error: "Failed to update units" }, status: :unprocessable_entity
    end
  end
end