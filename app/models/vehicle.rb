class Vehicle < ApplicationRecord
    belongs_to :room
    belongs_to :user

    validates :total_no_of_two_wheeler, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :total_no_of_four_wheeler, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    after_initialize :initialize_arrays

    private

    def initialize_arrays
        self.two_wheeler_numbers ||= []
        self.four_wheeler_numbers ||= []
    end
end
