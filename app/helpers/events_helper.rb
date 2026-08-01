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
end
