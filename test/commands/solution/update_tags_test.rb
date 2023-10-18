require "test_helper"

class Solution::UpdateTagsTest < ActiveSupport::TestCase
  test "update tags" do
    exercise = create :practice_exercise
    representation = create(:exercise_representation, exercise:)

    solution = create :practice_solution, :published, exercise:,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    iteration = create(:iteration, solution:)
    submission = create(:submission, solution:, iteration:, analysis_status: :completed)
    submission_tags = ["construct:throw", "paradigm:object-oriented"]
    create(:submission_representation, submission:, ast_digest: representation.ast_digest)
    create(:submission_analysis, submission:, tags_data: { tags: submission_tags })

    solution_tag_to_remove = create(:solution_tag, tag: 'uses:date.add_days', solution:)
    solution_tag_to_keep = create(:solution_tag, tag: submission_tags.first, solution:)

    assert_equal [solution_tag_to_remove.tag, solution_tag_to_keep.tag], solution.reload.tags.order(:id).pluck(:tag)

    Solution::UpdateTags.(solution)

    assert_equal [solution_tag_to_keep.tag, submission_tags.second], solution.reload.tags.order(:id).pluck(:tag)
    assert_raises ActiveRecord::RecordNotFound, &proc { solution_tag_to_remove.reload }
  end

  test "update exercise tags" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    Exercise::UpdateTags.expects(:call).with(exercise)

    Solution::UpdateTags.(solution)
  end
end
