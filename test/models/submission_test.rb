require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  test "statuses start at pending" do
    submission = create :submission
    assert submission.tests_not_queued?
    assert submission.representation_not_queued?
    assert submission.analysis_not_queued?
  end

  test "update solution's iteration_status" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    solution.expects(:update_iteration_status!).at_least_once

    submission.update(git_slug: "bar")
  end

  test "does not update iteration_status if no iteration" do
    solution = create :practice_solution
    submission = create :submission, solution: solution

    solution.expects(:update_iteration_status!).never

    submission.update(git_slug: "foo")
  end

  test "submissions get their solution's git data" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    assert_equal solution.git_sha, submission.git_sha
    assert_equal solution.git_slug, submission.git_slug
    assert_equal solution.git_important_files_hash, submission.git_important_files_hash
  end

  test "correct test_runs are retrieved" do
    exercise_hash = "exercise-hash"
    submission_sha = "submission-hash"

    exercise = create :practice_exercise, git_important_files_hash: exercise_hash
    submission = create :submission, git_sha: submission_sha, solution: create(:practice_solution, exercise: exercise)
    create :submission_test_run, submission: submission, git_sha: SecureRandom.uuid, git_important_files_hash: SecureRandom.uuid
    head_run = create :submission_test_run, submission: submission, git_sha: SecureRandom.uuid, git_important_files_hash: exercise_hash
    submission_run = create :submission_test_run, submission: submission, git_sha: submission_sha,
                                                  git_important_files_hash: SecureRandom.uuid
    create :submission_test_run, submission: submission, git_sha: SecureRandom.uuid, git_important_files_hash: SecureRandom.uuid

    # Sanity
    assert_equal exercise_hash, exercise.git_important_files_hash
    assert_equal exercise_hash, head_run.git_important_files_hash
    assert_equal submission_sha, submission.git_sha
    assert_equal submission_sha, submission_run.git_sha

    assert_equal 4, submission.test_runs.size
    assert_equal head_run, submission.head_test_run
    assert_equal submission_run, submission.test_run
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

  test "automated_feedback_pending" do
    # Pending without queued
    submission = create :submission, representation_status: :not_queued, analysis_status: :not_queued
    refute submission.automated_feedback_pending?

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
    submission = Submission.find(submission.id)
    refute submission.automated_feedback_pending?
    assert submission.has_automated_feedback?

    # Check if they're both completed but don't have feedback
    submission = create :submission, representation_status: :generated, analysis_status: :completed
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?

    # Check exceptioned states
    submission = create :submission, representation_status: :exceptioned, analysis_status: :exceptioned
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?

    # Check cancelled states
    submission = create :submission, representation_status: :cancelled, analysis_status: :cancelled
    refute submission.automated_feedback_pending?
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
        profile_url: nil
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
    iteration = create :iteration, solution: solution, submission: submission
    other_iteration = create :iteration, solution: solution

    assert submission.viewable_by?(student)
    refute submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    create :mentor_discussion, mentor: mentor_1, solution: solution
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    create :mentor_request, solution: solution, status: :fulfilled
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    create :mentor_request, solution: solution, status: :pending
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    solution.update(published_at: Time.current)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    assert submission.viewable_by?(user)
    assert submission.viewable_by?(nil)

    solution.update(published_iteration: other_iteration)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    solution.update(published_iteration: iteration)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    assert submission.viewable_by?(user)
    assert submission.viewable_by?(nil)
  end

  test "non-iteration submissions are never viewable" do
    student = create :user
    mentor_1 = create :user
    mentor_2 = create :user
    user = create :user, :not_mentor

    solution = create :concept_solution, user: student
    submission_1 = create :submission, solution: solution
    submission_2 = create :submission, solution: solution
    iteration = create :iteration, submission: submission_1, solution: solution
    create :mentor_discussion, mentor: mentor_1, solution: solution
    create :mentor_request, solution: solution

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

    # Check with published too
    solution.update(published_iteration: iteration)
    assert submission_1.viewable_by?(user)
    refute submission_2.viewable_by?(user)
  end

  test "valid_filepaths" do
    solution = create :concept_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission: submission, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission: submission, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission: submission, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission: submission, filename: ".meta/config.json" # Don't allow .meta
    create :submission_file, submission: submission, filename: ".docs/something.md" # Don't allow .docs
    create :submission_file, submission: submission, filename: ".exercism/config.json" # Don't allow .exercism

    assert_equal ["log_line_parser.rb", "subdir/new_file.rb"], submission.valid_filepaths
  end

  # The "d" track has both source and tests in the same file.
  # The config tells us this by having solution and test be the same
  test "valid_filepaths when test is same as solution file" do
    exercise = create :practice_exercise, slug: "d-like"
    solution = create :practice_solution, exercise: exercise
    submission = create :submission, solution: solution

    create :submission_file, submission: submission, filename: "source/bob.d"

    # Sanity
    repo = Git::Exercise.for_solution(solution)
    assert_equal repo.solution_filepaths, repo.test_filepaths

    # Check the file is allowed
    assert_equal ["source/bob.d"], submission.valid_filepaths
  end
end
