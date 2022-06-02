class Event < ApplicationRecord
  has_many :choices
  has_many :movies, through: :choices
  
end
