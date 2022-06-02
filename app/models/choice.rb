class Choice < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  belongs_to :event
  has_many :votes, dependent: :destroy

  validates :ranking, presence: true
  validates :movie, uniqueness: { scope: :event,
                          message: "Ce film est déjà dans la liste" }
end
