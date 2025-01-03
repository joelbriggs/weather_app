class Location < ApplicationRecord
    validates :address, presence: true
end
