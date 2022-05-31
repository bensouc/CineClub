class Choice < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  belongs_to :event

  validates :ranking, presence: true
end
