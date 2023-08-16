class Track::Trophy::Reseed
  include Mandate

  def call
    TROPHIES.each do |trophy|
      trophy.first&.reseed! || trophy.create!
    end
  end

  TROPHIES = [
    Track::Trophies::ReadFiftyCommunitySolutionsTrophy,
    Track::Trophies::MentoredTrophy,
    Track::Trophies::IteratedTwentyExercisesTrophy,
    Track::Trophies::CompletedTwentyExercisesTrophy,
    Track::Trophies::CompletedFiftyPercentOfExercisesTrophy,
    Track::Trophies::CompletedAllExercisesTrophy,
    Track::Trophies::FunctionalTrophy,
    Track::Trophies::CompletedLearningModeTrophy,
    Track::Trophies::CompletedFiveHardExercisesTrophy
  ].freeze
end
