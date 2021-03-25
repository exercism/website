require 'test_helper'

class Exercise::RepresentationTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "has markdown fields for feedback" do
    assert_markdown_field(:exercise_representation, :feedback)
  end

  test "has_feedback?" do
    user = create :user
    refute create(:exercise_representation, feedback_markdown: "foo", feedback_author: nil).has_feedback?
    refute create(:exercise_representation, feedback_markdown: nil, feedback_author: user).has_feedback?
    refute create(:exercise_representation, feedback_markdown: "foo", feedback_author: user).has_feedback?
    assert create(:exercise_representation, feedback_markdown: "foo", feedback_author: user,
                                            feedback_type: :non_actionable).has_feedback?
  end

  test "has_essential_feedback?" do
    refute create(:exercise_representation, feedback_type: :essential).has_essential_feedback?
    refute create(:exercise_representation, :with_feedback, feedback_type: :actionable).has_essential_feedback?
    assert create(:exercise_representation, :with_feedback, feedback_type: :essential).has_essential_feedback?
  end

  test "has_actionable_feedback?" do
    refute create(:exercise_representation, feedback_type: :actionable).has_actionable_feedback?
    refute create(:exercise_representation, :with_feedback, feedback_type: :essential).has_actionable_feedback?
    assert create(:exercise_representation, :with_feedback, feedback_type: :actionable).has_actionable_feedback?
  end

  test "has_non_actionable_feedback?" do
    refute create(:exercise_representation, feedback_type: :non_actionable).has_non_actionable_feedback?
    refute create(:exercise_representation, :with_feedback, feedback_type: :actionable).has_non_actionable_feedback?
    assert create(:exercise_representation, :with_feedback, feedback_type: :non_actionable).has_non_actionable_feedback?
  end

  test "num_times_used" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise
    submission = create :submission, solution: solution

    ast = SecureRandom.uuid
    ast_digest = Submission::Representation.digest_ast(ast)
    exercise_representation = create(:exercise_representation,
      exercise: exercise,
      ast: ast,
      ast_digest: ast_digest)
    assert_equal 0, exercise_representation.num_times_used

    create :submission_representation, submission: submission
    assert_equal 0, exercise_representation.num_times_used

    create :submission_representation, ast_digest: ast_digest, submission: submission
    assert_equal 1, exercise_representation.num_times_used

    create :submission_representation, ast_digest: ast_digest, submission: submission
    assert_equal 2, exercise_representation.num_times_used
  end

  test "self.order_by_frequency" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise
    submission = create :submission, solution: solution

    rare_ast_digest = SecureRandom.uuid
    medium_ast_digest = SecureRandom.uuid
    frequent_ast_digest = SecureRandom.uuid

    exercise_representation_medium = create(:exercise_representation, ast_digest: medium_ast_digest, exercise: exercise)
    exercise_representation_rare = create(:exercise_representation, ast_digest: rare_ast_digest, exercise: exercise)
    exercise_representation_frequent = create(:exercise_representation, ast_digest: frequent_ast_digest, exercise: exercise)

    2.times { create :submission_representation, ast_digest: medium_ast_digest, submission: submission }
    create :submission_representation, ast_digest: rare_ast_digest, submission: submission
    3.times { create :submission_representation, ast_digest: frequent_ast_digest, submission: submission }

    expected = [
      exercise_representation_frequent,
      exercise_representation_medium,
      exercise_representation_rare
    ]
    assert_equal expected, Exercise::Representation.order_by_frequency

    # Sanity check this is changing the order.
    refute_equal expected, Exercise::Representation.all
  end

  test "submission_representation" do
    exercise = create :concept_exercise
    ast = "My AST"
    ast_digest = Submission::Representation.digest_ast(ast)

    representation = create :exercise_representation,
      exercise: exercise,
      ast_digest: ast_digest

    # Wrong exercise
    create :submission_representation,
      submission: create(:submission),
      ast_digest: Submission::Representation.digest_ast(ast)

    assert_empty representation.reload.submission_representations

    # Wrong ast
    create :submission_representation,
      submission: create(:submission, exercise: exercise),
      ast_digest: "something"

    assert_empty representation.reload.submission_representations

    # Correct everything!
    submission_representation = create :submission_representation,
      submission: create(:submission, exercise: exercise),
      ast_digest: ast_digest

    assert_equal [submission_representation], representation.reload.submission_representations
  end
end
