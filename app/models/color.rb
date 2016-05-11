class Color < ActiveRecord::Base
	acts_as_voteable
	validates :color1, presence: true
end
