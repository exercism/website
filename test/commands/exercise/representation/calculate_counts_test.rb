require "test_helper"

class Exercise::Representation::CalculateCountsTest < ActiveSupport::TestCase
  test "mentor" do
    user_1 = create :user
    user_2 = create :user
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create(:practice_exercise, track: track_1)
    exercise_2 = create(:practice_exercise, track: track_2)
    create :exercise_representation, exercise: exercise_1, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise_1, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise_1, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise_1, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise_2, feedback_type: :actionable, feedback_author: user_2, num_submissions: 3

    expected = { without_feedback: 2, with_feedback: 2, admin: 3 }
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_1, track_2])

    expected = { without_feedback: 2, with_feedback: 1, admin: 3 }
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_2, [track_1, track_2])
  end

  test "tracks" do
    user_1 = create :user
    user_2 = create :user
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create(:practice_exercise, track: track_1)
    exercise_2 = create(:practice_exercise, track: track_2)
    create :exercise_representation, exercise: exercise_1, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise_1, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise_1, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise_2, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise_2, feedback_type: :actionable, feedback_author: user_2, num_submissions: 3

    expected = { without_feedback: 2, with_feedback: 1, admin: 1 }
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_1])
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_1.id])

    expected = { without_feedback: 0, with_feedback: 1, admin: 2 }
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_2])
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_2.id])

    expected = { without_feedback: 2, with_feedback: 2, admin: 3 }
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_1, track_2])
    assert_equal expected, Exercise::Representation::CalculateCounts.(user_1, [track_1.id, track_2.id])
  end
end
