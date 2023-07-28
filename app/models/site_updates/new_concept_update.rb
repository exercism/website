class SiteUpdates::NewConceptUpdate < SiteUpdate
  params :concept

  def guard_params = "Concept##{concept.id}"

  def i18n_params
    {
      concept_name: concept.name,
      concept_url: Exercism::Routes.track_concept_url(track, concept),
      maker_handles:
    }
  end

  def cacheable_rendering_data
    super.merge(
      makers: makers.map do |maker|
        {
          handle: maker.handle,
          avatar_url: maker.avatar_url,
          flair: maker.flair
        }
      end,
      concept_widget: {
        concept: {
          name: concept.name,
          slug: concept.slug,
          links: {
            self: Exercism::Routes.track_concept_path(track, concept),
            tooltip: Exercism::Routes.tooltip_track_concept_path(track, concept)
          }
        }
      }
    )
  end

  def icon
    {
      type: :concept,
      data: concept.name[0, 2]
    }
  end

  def maker_handles
    return "We" if makers.empty?
    return makers[0, 3].map(&:handle).to_sentence if makers.size <= 3

    "#{makers[0].handle}, #{makers[1].handle}, and #{makers.size - 2} others"
  end

  memoize
  def makers = concept.authors + concept.contributors
end
