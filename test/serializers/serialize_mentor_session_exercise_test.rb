require 'test_helper'

class SerializeMentorSessionExerciseTest < ActiveSupport::TestCase
  test "serializes" do
    exercise = create :concept_exercise

    expected = {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      links: {
        self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }

    assert_equal expected, SerializeMentorSessionExercise.(exercise)
  end
end
