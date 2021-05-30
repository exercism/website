require 'test_helper'

class SerializeContributorsTest < ActiveSupport::TestCase
  test "serializes correctly" do
    user_1 = create :user
    create :user_reputation_token, user: user_1

    user_2 = create :user
    create :user_reputation_token, user: user_2

    expected = [
      SerializeContributor.(user_1),
      SerializeContributor.(user_2)
    ]

    assert_equal expected, SerializeContributors.(
      [user_1, user_2]
    )
  end
  test "bulk-searches data correctly" do
    skip
    concept_exercise = create :concept_exercise
    practice_exercise = create :practice_exercise

    expected = [
      SerializeExercise.(concept_exercise),
      SerializeExercise.(practice_exercise)
    ]

    assert_equal expected, SerializeExercises.(
      [concept_exercise, practice_exercise]
    )
  end
end
