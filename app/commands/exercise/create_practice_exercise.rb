class Exercise::CreatePracticeExercise
  include Mandate

  initialize_with :uuid, :track, attributes: Mandate::KWARGS

  def call
    PracticeExercise.create!(
      uuid:,
      track:,
      **attributes
    ).tap do |exercise|
      SiteUpdates::ProcessNewExerciseUpdate.(exercise)
    end
  rescue ActiveRecord::RecordNotUnique
    PracticeExercise.find_by!(uuid:, track:)
  end
end
