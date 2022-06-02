class Choice < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  belongs_to :event

  validates :ranking, presence: true
  validates :movie, uniqueness:{ scope: :event,
    message: "Ce film est déjà dans la liste"}
end
