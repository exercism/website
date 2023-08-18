require "test_helper"

class Track::Trophy::ReseedVariableTest < ActiveSupport::TestCase
  test "reseed variable trophies" do
    create :mentored_trophy
    create :iterated_twenty_exercises_trophy
    create :completed_five_hard_exercises_trophy
    create :completed_learning_mode_trophy

    Track::Trophies::IteratedTwentyExercisesTrophy.any_instance.expects(:reseed!).never
    Track::Trophies::MentoredTrophy.any_instance.expects(:reseed!).never

    Track::Trophy::ReseedVariable::VARIABLE_TROPHIES.each do |trophy|
      trophy.any_instance.expects(:reseed!).once
    end

    Track::Trophy::ReseedVariable.()
  end
end
