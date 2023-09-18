class Track::Trophy::Reseed
  include Mandate

  def call
    TROPHIES.each do |trophy|
      trophy.first&.reseed! || trophy.create!
    end
  end

  TROPHIES = [
    #
    # General trophies
    #
    Track::Trophies::ReadFiftyCommunitySolutionsTrophy,
    Track::Trophies::MentoredTrophy,
    Track::Trophies::IteratedTwentyExercisesTrophy,
    Track::Trophies::CompletedTwentyExercisesTrophy,
    Track::Trophies::CompletedFiftyPercentOfExercisesTrophy,
    Track::Trophies::CompletedAllExercisesTrophy,
    Track::Trophies::FunctionalTrophy,
    #
    # Variable trophies
    #
    Track::Trophies::CompletedFiveHardExercisesTrophy,
    Track::Trophies::CompletedLearningModeTrophy
  ].freeze
end
