require "test_helper"

class Submission::LinkToApproachTest < ActiveSupport::TestCase
  test "link to approach with matching tag conditions" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    create(:exercise_approach_tag, :any, approach:, tag: "construct:lambda")
    create(:exercise_approach_tag, :any, approach:, tag: "technique:higher-order-function")
    create(:exercise_approach_tag, :not, approach:, tag: "paradigm:imperative")

    # This submission matches the requirements
    submission_1 = create(:submission, exercise:)
    create(:submission_analysis, submission: submission_1, tags_data: {
      tags: ["paradigm:functional", "construct:lambda"]
    })
    Submission::LinkToApproach.(submission_1)
    assert_equal approach, submission_1.approach

    # This submission matches the requirements via another :any tag
    submission_2 = create(:submission, exercise:)
    create(:submission_analysis, submission: submission_2, tags_data: {
      tags: ["paradigm:functional", "technique:higher-order-function"]
    })
    Submission::LinkToApproach.(submission_2)
    assert_equal approach, submission_2.approach
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

    Submission::LinkToApproach.(submission)

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

    Submission::LinkToApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when no tag condition matches" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: { tags: ["construct:if"] })

    Submission::LinkToApproach.(submission)

    assert_nil submission.approach
  end

  test "don't link to approach when submission does not have tags" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, :all, approach:, tag: "paradigm:functional")
    submission = create(:submission, exercise:)
    create(:submission_analysis, submission:, tags_data: nil)

    Submission::LinkToApproach.(submission)

    assert_nil submission.approach
  end
end
