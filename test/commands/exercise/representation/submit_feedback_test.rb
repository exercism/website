require "test_helper"

class Exercise::Representation::SubmitFeedbackTest < ActiveSupport::TestCase
  test "updates feedback of representation without feedback" do
    mentor = create :user
    representation = create :exercise_representation
    feedback_markdown = 'Try _this_'
    feedback_type = :actionable

    Exercise::Representation::SubmitFeedback.(mentor, representation, feedback_markdown, feedback_type)

    representation.reload
    assert_equal feedback_markdown, representation.feedback_markdown
    assert_equal feedback_type, representation.feedback_type
    assert_equal mentor, representation.feedback_author
    assert_nil representation.feedback_editor
  end

  test "updates feedback of representation with feedback" do
    author = create :user
    editor = create :user
    feedback_markdown = 'Try _this_'
    feedback_type = :actionable
    representation = create :exercise_representation, feedback_author: author, feedback_markdown: feedback_markdown,
      feedback_type: feedback_type

    Exercise::Representation::SubmitFeedback.(editor, representation, feedback_markdown, feedback_type)

    representation.reload
    assert_equal feedback_markdown, representation.feedback_markdown
    assert_equal feedback_type, representation.feedback_type
    assert_equal author, representation.feedback_author
    assert_equal editor, representation.feedback_editor
  end
end
