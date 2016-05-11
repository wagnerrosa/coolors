class Color < ActiveRecord::Base
	belongs_to :user

	validates :color1, presence: true
end
