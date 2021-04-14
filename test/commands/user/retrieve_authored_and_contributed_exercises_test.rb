require "test_helper"

class User::RetrieveAuthoredAndContributedExercisesTest < ActiveSupport::TestCase
  test "returns correct exercises" do
    user = create(:user_profile).user

    exercise_1 = create :practice_exercise
    exercise_2 = create :concept_exercise
    exercise_3 = create :practice_exercise
    create :concept_exercise

    exercise_1.authors << user
    exercise_2.contributors << user
    exercise_3.authors << create(:user)

    actual = User::RetrieveAuthoredAndContributedExercises.(user)

    expected = Exercise.
      where(id: [exercise_1, exercise_2].map(&:id)).
      order(id: :desc).
      page(1).per(20)

    assert_equal expected, actual
  end
end
