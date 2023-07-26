class Concept::Create
  include Mandate

  initialize_with :uuid, :track, attributes: Mandate::KWARGS

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
