class Event < ApplicationRecord
  has_many :choices, dependent: :destroy
  has_many :movies, through: :choices

  # Où se tient la séance. La colonne est non-null avec un défaut "indoor",
  # donc un event a toujours une valeur — d'où l'absence de validation de
  # présence : elle serait toujours satisfaite.
  enum :venue, { indoor: "indoor", outdoor: "outdoor" }

  validates :name, presence: true
  validates :date, presence: true

  # Choices best-ranked first. Sorted in Ruby rather than SQL so it reuses a
  # preloaded :choices association instead of firing a fresh query per call.
  def ranked_choices
    choices.sort_by { |choice| -choice.ranking.to_i }
  end

  # Distinct users who cast at least one vote in this event, across all its
  # choices. Uses the preloaded :choices/:votes/:user associations (see
  # EventsController#index) so the list page stays free of N+1 queries.
  def voters
    choices.flat_map(&:votes).map(&:user).uniq(&:id)
  end

  # True when the top two choices are tied on votes, so the index page knows to
  # show both posters instead of a single winner.
  def exequo?
    ranked = ranked_choices
    ranked.size >= 2 && ranked[0].ranking == ranked[1].ranking
  end
end
