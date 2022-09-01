require "test_helper"

class Exercise::Representation::SubmitFeedbackTest < ActiveSupport::TestCase
  test "adds feedback" do
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

  test "adding feedback awards automation feedback author reputation token" do
    mentor = create :user
    representation = create :exercise_representation
    feedback_markdown = 'Try _this_'
    feedback_type = :actionable

    # Sanity check
    refute User::ReputationTokens::AutomationFeedbackAuthorToken.where(user: mentor).exists?
    refute User::ReputationTokens::AutomationFeedbackEditorToken.where(user: mentor).exists?

    perform_enqueued_jobs do
      Exercise::Representation::SubmitFeedback.(mentor, representation, feedback_markdown, feedback_type)
    end

    assert User::ReputationTokens::AutomationFeedbackAuthorToken.where(user: mentor).exists?
    refute User::ReputationTokens::AutomationFeedbackEditorToken.where(user: mentor).exists?
  end

  test "updates feedback" do
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

  test "updating feedback awards automation feedback editor reputation token" do
    editor = create :user
    author = create :user
    feedback_markdown = 'Try _this_'
    feedback_type = :actionable
    representation = create :exercise_representation, feedback_author: author, feedback_markdown: feedback_markdown,
      feedback_type: feedback_type

    # Sanity check
    refute User::ReputationTokens::AutomationFeedbackAuthorToken.where(user: editor).exists?
    refute User::ReputationTokens::AutomationFeedbackEditorToken.where(user: editor).exists?

    perform_enqueued_jobs do
      Exercise::Representation::SubmitFeedback.(editor, representation, feedback_markdown, feedback_type)
    end

    assert User::ReputationTokens::AutomationFeedbackEditorToken.where(user: editor).exists?
    refute User::ReputationTokens::AutomationFeedbackAuthorToken.where(user: editor).exists?
    refute User::ReputationTokens::AutomationFeedbackEditorToken.where(user: author).exists?
  end

  test "updating feedback does not award automation feedback editor reputation token if user is author" do
    mentor = create :user
    feedback_markdown = 'Try _this_'
    feedback_type = :actionable
    representation = create :exercise_representation, feedback_author: mentor, feedback_markdown: feedback_markdown,
      feedback_type: feedback_type

    # Sanity check
    refute User::ReputationTokens::AutomationFeedbackEditorToken.where(user: mentor).exists?

    perform_enqueued_jobs do
      Exercise::Representation::SubmitFeedback.(mentor, representation, feedback_markdown, feedback_type)
    end

    refute User::ReputationTokens::AutomationFeedbackEditorToken.where(user: mentor).exists?
  end
end
