module EventsHelper
  # Badge intérieur / extérieur, partagé par la liste et la fiche d'une soirée.
  # L'extérieur (ciné plein-air) porte l'accent marquee pour ressortir ; l'intérieur
  # reste discret.
  def venue_badge(event, extra_class: "")
    outdoor = event.outdoor?
    tone = outdoor ? "bg-marquee/15 text-marquee-ink" : "bg-reel/5 text-muted"

    tag.span class: "inline-flex w-fit items-center gap-1 rounded-full px-2.5 py-0.5 " \
                    "text-[11px] font-bold uppercase tracking-wider #{tone} #{extra_class}" do
      concat icon(outdoor ? :palm : :sofa, size: "size-3")
      concat(outdoor ? "Salle Pelouse" : "Salle Canapé")
    end
  end

  # "Qui a voté" : petits ronds d'initiales qui se chevauchent (façon liste
  # d'invités) + le compte. Rien n'est rendu si personne n'a voté, pour ne pas
  # charger les cartes des soirées sans participation.
  def voters_stack(event)
    voters = event.voters
    return if voters.empty?

    dot = "flex size-6 items-center justify-center rounded-full border-2 border-card text-[10px] font-bold"

    tag.div class: "mt-1 flex items-center gap-2" do
      concat(tag.div(class: "flex -space-x-1.5") do
        voters.first(3).each do |user|
          concat tag.span(user.email[0].upcase, class: "#{dot} bg-marquee/25 text-marquee-ink")
        end
        if voters.size > 3
          concat tag.span("+#{voters.size - 3}", class: "#{dot} bg-reel text-paper")
        end
      end)
      concat tag.span("#{voters.size} #{voters.size > 1 ? 'ont voté' : 'a voté'}",
                      class: "text-xs text-muted")
    end
  end
end
