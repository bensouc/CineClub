class Event < ApplicationRecord
  has_many :choices
  has_many :movies, through: :choices

  def exequo?
    choices = self.choices.order(ranking: :desc)
    return false if choices.count < 2

    return true if choices.first.ranking == choices[1].ranking

    return false
  end
end
