class CreateTrackTrophies < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :track_trophies do |t|
      t.string :type, null: false
      t.json :valid_track_slugs, null: true
      t.timestamps

      t.index :type, unique: true
    end

    TROPHIES.each do |trophy|
      trophy.create!
    end    
  end

  TROPHIES = [
    Track::Trophies::General::CompletedAllExercisesTrophy,
    Track::Trophies::General::ReadFiftyCommunitySolutionsTrophy,
    Track::Trophies::General::MentoredTrophy,
    Track::Trophies::General::IteratedTwentyExercisesTrophy,
    Track::Trophies::General::CompletedTwentyExercisesTrophy,
    Track::Trophies::General::CompletedFiftyPercentOfExercisesTrophy,
    Track::Trophies::Shared::FunctionalTrophy,
    Track::Trophies::Shared::CompletedLearningModeTrophy,
    Track::Trophies::Shared::CompletedFiveHardExercisesTrophy
  ].freeze
  private_constant :TROPHIES
end
