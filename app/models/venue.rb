class Venue < ApplicationRecord
  has_many :events, dependent: :destroy
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode
end
