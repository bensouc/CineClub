class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :choice

  validates :user,  uniqueness:{ scope: :choice,
    message: "Tu as déjà voté pour ce film"}
end
