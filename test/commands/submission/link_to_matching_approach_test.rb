require "test_helper"

class Submission::LinkToMatchingApproachTest < ActiveSupport::TestCase
  test "link to approach with matching tag conditions" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    create(:exercise_approach_tag, :any, approach:, tag: "construct:lambda")
    create(:exercise_approach_tag, :any, approach:, tag: "technique:higher-order-function")
    create(:exercise_approach_tag, :not, approach:, tag: "paradigm:imperative")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: {
      tags: ["paradigm:functional", "construct:lambda"]
    })

    Submission::LinkToMatchingApproach.(submission)

    assert_equal approach, submission.approach
  end

  test "don't link to approach when none of the :any tag conditions match" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :any, approach:, tag: "construct:while")
    create(:exercise_approach_tag, :any, approach:, tag: "construct:for")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: {
      tags: ["construct:if"]
    })

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when :not tag condition matches" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    create(:exercise_approach_tag, :not, approach:, tag: "paradigm:imperative")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: {
      tags: ["paradigm:functional", "paradigm:imperative"]
    })

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when no tag condition matches" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: { tags: ["construct:if"] })

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when submission does not have tags" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: nil)

    Submission::LinkToMatchingApproach.(submission)

    assert_nil submission.approach
  end
end
