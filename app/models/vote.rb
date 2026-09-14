class Vote < ApplicationRecord
  belongs_to :color, counter_cache: true

  validates :voter_key, presence: true, uniqueness: { scope: :color_id }
end
