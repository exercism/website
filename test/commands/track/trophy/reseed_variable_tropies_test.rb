require "test_helper"

class Track::Trophy::ReseedVariableTrophiesTest < ActiveSupport::TestCase
  test "reseed variable trophies" do
    create :mentored_trophy
    create :iterated_twenty_exercises_trophy
    create :completed_five_hard_exercises_trophy
    create :completed_learning_mode_trophy

    Track::Trophies::IteratedTwentyExercisesTrophy.any_instance.expects(:reseed!).never
    Track::Trophies::MentoredTrophy.any_instance.expects(:reseed!).never
    Track::Trophies::CompletedFiveHardExercisesTrophy.any_instance.expects(:reseed!).once
    Track::Trophies::CompletedLearningModeTrophy.any_instance.expects(:reseed!).once

    Track::Trophy::ReseedVariableTrophies.()
  end
end
