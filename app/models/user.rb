class User < ApplicationRecord
  # Registration and recovery stay off by design: this app has exactly one
  # admin account, seeded from ENV. (2016: "just me to manage the trolls")
  devise :database_authenticatable, :rememberable, :trackable, :validatable
end
