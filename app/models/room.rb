class Room < ApplicationRecord
  belongs_to :floor
  belongs_to :block
  has_many :users, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  validates :room_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # attribute :floor_number, :integer

  def update_units
    room = Room.find(params[:room_id])
    room.total_units = params[:total_units]  

    if room.save
      render json: { message: "Units updated successfully" }, status: :ok
    else
      render json: { error: "Failed to update units" }, status: :unprocessable_entity
    end
  end
end