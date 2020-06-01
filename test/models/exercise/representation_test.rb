require 'test_helper'

class Exercise::RepresentationTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "has markdown fields for feedback" do
    assert_markdown_field(:exercise_representation, :feedback)
  end

  test "pending?" do
    assert create(:exercise_representation, action: :pending).pending?
    refute create(:exercise_representation, action: :approve).pending?
    refute create(:exercise_representation, action: :disapprove).pending?
  end

  test "approve?" do
    refute create(:exercise_representation, action: :pending).approve?
    assert create(:exercise_representation, action: :approve).approve?
    refute create(:exercise_representation, action: :disapprove).approve?
  end

  test "disapprove?" do
    refute create(:exercise_representation, action: :pending).disapprove?
    refute create(:exercise_representation, action: :approve).disapprove?
    assert create(:exercise_representation, action: :disapprove).disapprove?
  end

  test "has_feedback?" do
    refute create(:exercise_representation, feedback_markdown: "foo", feedback_author: nil).has_feedback?
    refute create(:exercise_representation, feedback_markdown: nil, feedback_author: create(:user)).has_feedback?
    assert create(:exercise_representation, feedback_markdown: "foo", feedback_author: create(:user)).has_feedback?
  end

  test "num_times_used" do
    ast = SecureRandom.uuid
    exercise_representation = create(:exercise_representation, ast: ast, ast_digest: Iteration::Representation.digest_ast(ast))
    assert_equal 0, exercise_representation.num_times_used

    create :iteration_representation
    assert_equal 0, exercise_representation.num_times_used

    create :iteration_representation, ast: ast
    assert_equal 1, exercise_representation.num_times_used

    create :iteration_representation, ast: ast
    assert_equal 2, exercise_representation.num_times_used
  end

  test "self.order_by_frequency" do
    rare_ast = SecureRandom.uuid
    medium_ast = SecureRandom.uuid
    frequent_ast = SecureRandom.uuid
    exercise_representation_medium = create(:exercise_representation, ast_digest: Iteration::Representation.digest_ast(medium_ast))
    exercise_representation_rare = create(:exercise_representation, ast_digest: Iteration::Representation.digest_ast(rare_ast))
    exercise_representation_frequent = create(:exercise_representation, ast_digest: Iteration::Representation.digest_ast(frequent_ast))

    2.times { create :iteration_representation, ast: medium_ast }
    1.times { create :iteration_representation, ast: rare_ast }
    3.times { create :iteration_representation, ast: frequent_ast }

    expected = [
      exercise_representation_frequent, 
      exercise_representation_medium, 
      exercise_representation_rare
    ]
    assert_equal expected, Exercise::Representation.order_by_frequency

    # Sanity check this is changing the order.
    refute_equal expected, Exercise::Representation.all
  end
end
