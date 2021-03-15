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

  test "automated_feedback_pending without feedback" do
    # Pending without queued
    submission = create :submission, representation_status: :not_queued, analysis_status: :not_queued
    assert submission.automated_feedback_pending?

    # Pending with queued
    submission = create :submission, representation_status: :queued, analysis_status: :queued
    assert submission.automated_feedback_pending?

    # Present only if there is actual feedback on representation
    submission = create :submission, representation_status: :generated, analysis_status: :queued
    assert submission.automated_feedback_pending?

    create :submission_representation, ast_digest: "foobar", submission: submission
    er = create :exercise_representation, ast_digest: "foobar", exercise: submission.exercise
    assert Submission.find(submission.id).automated_feedback_pending?

    er.update!(feedback_markdown: "foobar", feedback_author: create(:user), feedback_type: :non_actionable)
    submission = Submission.find(submission.id)
    refute submission.automated_feedback_pending?
    refute submission.has_essential_automated_feedback?
    refute submission.has_actionable_automated_feedback?
    assert submission.has_non_actionable_automated_feedback?

    er.update!(feedback_type: :actionable)
    submission = Submission.find(submission.id)
    refute submission.automated_feedback_pending?
    refute submission.has_essential_automated_feedback?
    assert submission.has_actionable_automated_feedback?
    refute submission.has_non_actionable_automated_feedback?

    er.update!(feedback_type: :essential)
    submission = Submission.find(submission.id)
    refute submission.automated_feedback_pending?
    assert submission.has_essential_automated_feedback?
    refute submission.has_actionable_automated_feedback?
    refute submission.has_non_actionable_automated_feedback?

    # Present only if there is actual feedback on analysis
    submission = create :submission, representation_status: :queued, analysis_status: :completed
    assert submission.automated_feedback_pending?

    sa = create :submission_analysis, submission: submission
    assert Submission.find(submission.id).automated_feedback_pending?

    sa.update(data: { comments: ['asd'] })
    assert Submission.find(submission.id).has_automated_feedback?

    # Finally, check if they're both completed but don't have feedback
    submission = create :submission, representation_status: :generated, analysis_status: :completed
    refute submission.has_automated_feedback?
  end

  test "representer_feedback is correctly nil" do
    submission = create :submission, representation_status: :generated
    assert_nil submission.representer_feedback

    create :submission_representation, ast_digest: "foobar", submission: submission
    submission = Submission.find(submission.id)
    assert_nil submission.representer_feedback

    er = create :exercise_representation, ast_digest: "foobar", exercise: submission.exercise
    submission = Submission.find(submission.id)
    assert_nil submission.representer_feedback

    er.update!(feedback_markdown: "foobar", feedback_author: create(:user), feedback_type: :essential)
    submission = Submission.find(submission.id)
    assert submission.representer_feedback
  end

  test "analyzer_feedback is correctly nil" do
    submission = create :submission, analysis_status: :completed
    assert_nil submission.analyzer_feedback

    sa = create :submission_analysis, submission: submission
    submission = Submission.find(submission.id)
    assert_nil submission.reload.analyzer_feedback

    sa.update(data: { comments: ['asd'] })
    submission = Submission.find(submission.id)
    assert submission.reload.analyzer_feedback
  end

  test "representer_feedback is populated correctly" do
    reputation = 50
    author = create :user, reputation: reputation
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, representation_status: :generated
    create :submission_representation, ast_digest: ast_digest, submission: submission
    create :exercise_representation, ast_digest: ast_digest, exercise: submission.exercise,
                                     feedback_markdown: markdown, feedback_author: author, feedback_type: :essential

    expected = {
      html: "<p>foobar</p>\n",
      author: {
        name: author.name,
        reputation: 50,
        avatar_url: author.avatar_url,
        profile_url: "#"
      }
    }
    assert_equal expected, submission.representer_feedback
  end

  test "analyzer_feedback is populated correctly" do
    TestHelpers.use_website_copy_test_repo!

    reputation = 50
    author = create :user, reputation: reputation
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, analysis_status: :completed
    create :submission_analysis, submission: submission, data: {
      summary: "Some summary",
      comments: ["ruby.two-fer.incorrect_default_param"]
    }
    create :exercise_representation, ast_digest: ast_digest, exercise: submission.exercise,
                                     feedback_markdown: markdown, feedback_author: author

    expected = {
      summary: "Some summary",
      comments: [
        {
          type: :informative,
          html: "<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>\n" # rubocop:disable Layout/LineLength
        }
      ]
    }
    assert_equal expected, submission.analyzer_feedback
  end

  test "viewable_by pivots correctly" do
    student = create :user
    mentor_1 = create :user
    mentor_2 = create :user
    user = create :user, :not_mentor

    solution = create :concept_solution, user: student
    submission = create :submission, solution: solution
    create :iteration, solution: solution, submission: submission

    assert submission.viewable_by?(student)
    refute submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)

    create :solution_mentor_discussion, mentor: mentor_1, solution: solution
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)

    create :solution_mentor_request, solution: solution, status: :fulfilled
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)

    create :solution_mentor_request, solution: solution, status: :pending
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)

    solution.update(published_at: Time.current)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    assert submission.viewable_by?(user)
  end

  test "non-iteration submissions are never viewable" do
    student = create :user
    mentor_1 = create :user
    mentor_2 = create :user
    user = create :user, :not_mentor

    solution = create :concept_solution, user: student
    submission_1 = create :submission, solution: solution
    submission_2 = create :submission, solution: solution
    create :iteration, submission: submission_1, solution: solution
    create :solution_mentor_discussion, mentor: mentor_1, solution: solution
    create :solution_mentor_request, solution: solution

    # Normal state
    assert submission_1.viewable_by?(student)
    assert submission_1.viewable_by?(mentor_1)
    assert submission_1.viewable_by?(mentor_2)
    refute submission_1.viewable_by?(user)

    assert submission_2.viewable_by?(student)
    refute submission_2.viewable_by?(mentor_1)
    refute submission_2.viewable_by?(mentor_2)
    refute submission_2.viewable_by?(user)

    # Check with published too
    solution.update(published_at: Time.current)
    assert submission_1.viewable_by?(user)
    refute submission_2.viewable_by?(user)
  end
end
