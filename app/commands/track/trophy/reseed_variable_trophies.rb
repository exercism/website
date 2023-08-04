class Track::Trophy::ReseedVariableTrophies
  include Mandate

  def call
    VARIABLE_TROPHIES.each do |trophy|
      trophy.first&.reseed!
    end
  end

  VARIABLE_TROPHIES = [
    Track::Trophies::Shared::CompletedFiveHardExercisesTrophy,
    Track::Trophies::Shared::CompletedLearningModeTrophy
  ].freeze
end
