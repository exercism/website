require 'test_helper'

class SerializeSiteUpdatesTest < ActiveSupport::TestCase
  test "serializes unexpanded new_exercise_update" do
    update = create :new_exercise_site_update

    expected = [
      update.rendering_data
    ]

    assert_equal expected, SerializeSiteUpdates.([update])
  end

  test "serializes new_exercise_update without user" do
    update = create :new_exercise_site_update
    update.stubs(expanded?: true)

    expected = [
      update.rendering_data.merge(
        exercise_widget: AssembleExerciseWidget.(
          update.exercise,
          nil,
          solution: nil,
          with_tooltip: false,
          render_blurb: true,
          render_track: true,
          recommended: false,
          skinny: false
        )
      )
    ]

    assert_equal expected, SerializeSiteUpdates.([update])
  end

  test "serializes new_exercise_update with user" do
    exercise = create :practice_exercise
    user = create :user
    solution = create(:practice_solution, exercise:, user:)
    user_track = create :user_track, user:, track: exercise.track
    update = create(:new_exercise_site_update, exercise:)
    update.stubs(expanded?: true)

    expected = [
      update.rendering_data.merge(
        exercise_widget: AssembleExerciseWidget.(
          update.exercise,
          user_track,
          solution:,
          with_tooltip: false,
          render_blurb: true,
          render_track: true,
          recommended: false,
          skinny: false
        )
      )
    ]
    assert_equal expected, SerializeSiteUpdates.([update], user:)
  end

  test "serializes new_concept_update" do
    update = create :new_concept_site_update

    update.stubs(expanded?: false)
    assert_equal [update.rendering_data], SerializeSiteUpdates.([update])

    update.stubs(expanded?: true)
    assert_equal [update.rendering_data], SerializeSiteUpdates.([update])
  end
end
