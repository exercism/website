class Track::Trophy::ReseedVariable
  include Mandate

  def call
    VARIABLE_TROPHIES.each do |trophy|
      trophy.first&.reseed!
    end
  end

  VARIABLE_TROPHIES = [
    Track::Trophies::CompletedFiveHardExercisesTrophy,
    Track::Trophies::CompletedLearningModeTrophy
  ].freeze
end
