class Color < ActiveRecord::Base
	acts_as_votable
	belongs_to :user

	validates :color1, presence: true
end
