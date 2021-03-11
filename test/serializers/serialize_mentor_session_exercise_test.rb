require 'test_helper'

class SerializeMentorSessionExerciseTest < ActiveSupport::TestCase
  test "serializes" do
    exercise = create :concept_exercise

    expected = {
      id: exercise.slug,
      title: exercise.title,
      icon_name: exercise.icon_name
    }

    assert_equal expected, SerializeMentorSessionExercise.(exercise)
  end
end
