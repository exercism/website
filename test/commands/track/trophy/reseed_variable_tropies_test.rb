require "test_helper"

class Track::Trophy::ReseedVariableTrophiesTest < ActiveSupport::TestCase
  test "reseed variable trophies" do
    create :mentored_trophy
    create :iterated_twenty_exercises_trophy
    create :completed_five_hard_exercises_trophy
    create :completed_learning_mode_trophy

    Track::Trophies::General::IteratedTwentyExercisesTrophy.any_instance.expects(:reseed!).never
    Track::Trophies::General::MentoredTrophy.any_instance.expects(:reseed!).never
    Track::Trophies::Shared::CompletedFiveHardExercisesTrophy.any_instance.expects(:reseed!).once
    Track::Trophies::Shared::CompletedLearningModeTrophy.any_instance.expects(:reseed!).once

    Track::Trophy::ReseedVariableTrophies.()
  end
end
