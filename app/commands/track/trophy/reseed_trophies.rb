class Track::Trophy::ReseedTrophies
  include Mandate

  def call
    TROPHIES.each do |trophy|
      trophy.first&.reseed! || trophy.create!
    end

    Track::Trophy::ReseedVariableTrophies.()
  end

  TROPHIES = [
    Track::Trophies::General::ReadFiftyCommunitySolutionsTrophy,
    Track::Trophies::General::MentoredTrophy,
    Track::Trophies::General::IteratedTwentyExercisesTrophy,
    Track::Trophies::General::CompletedTwentyExercisesTrophy,
    Track::Trophies::General::CompletedFiftyPercentOfExercisesTrophy,
    Track::Trophies::General::CompletedAllExercisesTrophy,
    Track::Trophies::Shared::FunctionalTrophy,
    Track::Trophies::Shared::CompletedLearningModeTrophy,
    Track::Trophies::Shared::CompletedFiveHardExercisesTrophy
  ].freeze
end
