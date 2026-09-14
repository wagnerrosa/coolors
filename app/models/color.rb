class Color < ApplicationRecord
  has_many :votes, dependent: :destroy

  validates :color1, presence: true
end
