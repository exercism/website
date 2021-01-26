require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  test "statuses start at pending" do
    submission = create :submission
    assert submission.tests_not_queued?
    assert submission.representation_not_queued?
    assert submission.analysis_not_queued?
  end

  test "submissions get their solution's git data" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    assert_equal solution.git_sha, submission.git_sha
    assert_equal solution.git_slug, submission.git_slug
  end

  test "exercise_representation" do
    ast = "foobar"

    # No submission_representation
    submission = create :submission
    assert_nil submission.exercise_representation

    # Ops error submission rep
    sr = create :submission_representation, submission: submission, ast: ast, ops_status: 500
    submission = Submission.find(submission.id)
    assert_nil submission.exercise_representation

    # Missing exercise_reprsentation
    sr.update!(ops_status: 200)
    submission = Submission.find(submission.id)
    assert_nil submission.exercise_representation

    # er present
    er = create :exercise_representation, exercise: submission.exercise, ast_digest: sr.ast_digest
    submission = Submission.find(submission.id)
    assert_equal er, submission.exercise_representation
  end

  test "automated_feedback_status without feedback" do
    # Pending without queued
    submission = create :submission, representation_status: :not_queued, analysis_status: :not_queued
    assert_equal :pending, submission.automated_feedback_status

    # Pending with queued
    submission = create :submission, representation_status: :queued, analysis_status: :queued
    assert_equal :pending, submission.automated_feedback_status

    # Present only if there is acutal feedback on representation
    submission = create :submission, representation_status: :generated, analysis_status: :queued
    assert_equal :pending, submission.automated_feedback_status

    create :submission_representation, ast_digest: "foobar", submission: submission
    er = create :exercise_representation, ast_digest: "foobar", exercise: submission.exercise
    assert_equal :pending, Submission.find(submission.id).automated_feedback_status

    er.update!(feedback_markdown: "foobar", feedback_author: create(:user))
    assert_equal :present, Submission.find(submission.id).automated_feedback_status

    # Present only if there is actual feedback on analysis
    submission = create :submission, representation_status: :queued, analysis_status: :completed
    assert_equal :pending, submission.automated_feedback_status

    sa = create :submission_analysis, submission: submission
    assert_equal :pending, Submission.find(submission.id).automated_feedback_status

    sa.update(data: { comments: ['asd'] })
    assert_equal :present, Submission.find(submission.id).automated_feedback_status

    # None if they're both completed but don't have feedback
    submission = create :submission, representation_status: :generated, analysis_status: :completed
    assert_equal :none, submission.automated_feedback_status
  end

  test "has_automated_feedback? with representation" do
    submission = create :submission, representation_status: :generated
    refute submission.has_automated_feedback?

    create :submission_representation, ast_digest: "foobar", submission: submission
    submission = Submission.find(submission.id)
    refute submission.has_automated_feedback?

    er = create :exercise_representation, ast_digest: "foobar", exercise: submission.exercise
    submission = Submission.find(submission.id)
    refute submission.has_automated_feedback?

    er.update!(feedback_markdown: "foobar", feedback_author: create(:user))
    submission = Submission.find(submission.id)
    assert submission.has_automated_feedback?
  end

  test "has_automated_feedback? with analysis" do
    submission = create :submission, analysis_status: :completed
    refute submission.has_automated_feedback?

    sa = create :submission_analysis, submission: submission
    submission = Submission.find(submission.id)
    refute submission.reload.has_automated_feedback?

    sa.update(data: { comments: ['asd'] })
    submission = Submission.find(submission.id)
    assert submission.reload.has_automated_feedback?
  end

  test "automated_feedback for representer" do
    reputation = 50
    author = create :user, reputation: reputation
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, representation_status: :generated
    create :submission_representation, ast_digest: ast_digest, submission: submission
    create :exercise_representation, ast_digest: ast_digest, exercise: submission.exercise,
                                     feedback_markdown: markdown, feedback_author: author

    expected = {
      html: "<p>foobar</p>\n",
      author: {
        name: author.name,
        reputation: 50,
        avatar_url: author.avatar_url,
        profile_url: "#"
      }
    }
    assert_equal expected, submission.automated_feedback
  end

  test "automated_feedback for analysis" do
    reputation = 50
    author = create :user, reputation: reputation
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, analysis_status: :completed
    create :submission_analysis, submission: submission, data: {
      comments: ["ruby.two-fer.incorrect_default_param"]
    }
    create :exercise_representation, ast_digest: ast_digest, exercise: submission.exercise,
                                     feedback_markdown: markdown, feedback_author: author

    expected = {
      html: "<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>\n", # rubocop:disable Layout/LineLength
      author: {
        name: "The #{submission.track.title} Analysis Team",
        avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4", # TODO
        profile_url: "#"
      }
    }
    assert_equal expected, submission.automated_feedback
  end

  test "automated_feedback returns nil if has_automated_feedback? is false" do
    submission = create :submission
    refute submission.has_automated_feedback?
    assert_nil submission.automated_feedback
  end
end
