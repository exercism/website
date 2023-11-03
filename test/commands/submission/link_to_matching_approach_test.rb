require "test_helper"

class Submission::LinkToMatchingApproachTest < ActiveSupport::TestCase
  test "link to approach with matching tag conditions" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags: {
      "all" => ["paradigm:functional"],
      "any" => %w[construct:lambda technique:higher-order-function],
      "not" => ["paradigm:imperative"]
    })

    submission = create(:submission, exercise:, tags: %w[paradigm:functional construct:lambda])

    Submission::LinkToMatchingApproach.(submission)

    assert_equal approach, submission.approach
  end

  test "don't link to approach when none of the :any tag conditions match" do
    exercise = create :practice_exercise
    create(:exercise_approach, exercise:, tags: { "any" => %w[construct:while construct:for] })
    submission = create(:submission, exercise:, tags: ["construct:if"])

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when :not tag condition matches" do
    exercise = create :practice_exercise
    create(:exercise_approach, exercise:, tags: {
      "all" => ["paradigm:functional"],
      "not" => ["paradigm:imperative"]
    })
    submission = create(:submission, exercise:, tags: %w[paradigm:functional paradigm:imperative])

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when no tag condition matches" do
    exercise = create :practice_exercise
    create(:exercise_approach, exercise:, tags: { "all" => ["paradigm:functional"] })
    submission = create(:submission, exercise:, tags: ["construct:if"])

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when submission does not have tags" do
    exercise = create :practice_exercise
    create(:exercise_approach, exercise:, tags: { "all" => ["paradigm:functional"] })
    submission = create(:submission, exercise:, tags: nil)

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end
end
