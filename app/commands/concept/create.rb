class Concept
  class Create
    include Mandate

    initialize_with :uuid, :track, :attributes

    def call
      Concept.create!(
        uuid:,
        track:,
        **attributes
      ).tap do |concept|
        SiteUpdates::NewConceptUpdate.create!(
          track:,
          params: {
            concept:
          }
        )
      end
    rescue ActiveRecord::RecordNotUnique
      Concept.find_by!(uuid:, track:)
    end
  end
end
