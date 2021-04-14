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
      page(1).per(25)

    assert_equal expected, actual
  end

  test "sorting works" do
    user = create :user
    exercise_1 = create :practice_exercise
    exercise_2 = create :practice_exercise
    create :exercise_authorship, author: user, exercise: exercise_1
    create :exercise_authorship, author: user, exercise: exercise_2

    assert_equal [exercise_2, exercise_1], User::RetrieveAuthoredAndContributedExercises.(user)
    assert_equal [exercise_1, exercise_2], User::RetrieveAuthoredAndContributedExercises.(user, sorted: false)
  end

  test "returns relationship unless paginated" do
    user = create :user
    create :exercise_authorship, author: user

    exercises = User::RetrieveAuthoredAndContributedExercises.(user, paginated: false)
    assert exercises.is_a?(ActiveRecord::Relation)
    refute_respond_to exercises, :current_page
  end
end
