class Event < ApplicationRecord
  has_many :choices, dependent: :destroy
  has_many :movies, through: :choices

  validates :name, presence: true
  validates :date, presence: true

  # Choices best-ranked first. Sorted in Ruby rather than SQL so it reuses a
  # preloaded :choices association instead of firing a fresh query per call.
  def ranked_choices
    choices.sort_by { |choice| -choice.ranking.to_i }
  end

  # True when the top two choices are tied on votes, so the index page knows to
  # show both posters instead of a single winner.
  def exequo?
    ranked = ranked_choices
    ranked.size >= 2 && ranked[0].ranking == ranked[1].ranking
  end
end
