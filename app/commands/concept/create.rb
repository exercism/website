class Concept
  class Create
    include Mandate

    initialize_with :uuid, :track, :attributes

    def call
      Concept.create!(
        uuid: uuid,
        track: track,
        **attributes
      ).tap do |concept|
        SiteUpdates::NewConceptUpdate.create!(
          track: track,
          params: {
            concept: concept
          }
        )
      end
    rescue ActiveRecord::RecordNotUnique
      Track::Concept.find_by!(uuid: uuid, track: track)
    end
  end
end
