class Exercise::CreateConceptExercise
  include Mandate

  initialize_with :uuid, :track, attributes: Mandate::KWARGS

  def call
    ConceptExercise.create!(
      uuid:,
      track:,
      **attributes
    ).tap do |exercise|
      SiteUpdates::ProcessNewExerciseUpdate.(exercise)
    end
  rescue ActiveRecord::RecordNotUnique
    ConceptExercise.find_by!(uuid:, track:)
  end
end
