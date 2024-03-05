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
    submission = create(:submission, solution:)
    create(:iteration, submission:)

    solution.expects(:update_iteration_status!).at_least_once

    submission.update(git_slug: "bar")
  end

  test "does not update iteration_status if no iteration" do
    solution = create :practice_solution
    submission = create(:submission, solution:)

    solution.expects(:update_iteration_status!).never

    submission.update(git_slug: "foo")
  end

  test "submissions get their solution's git data" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    assert_equal solution.git_sha, submission.git_sha
    assert_equal solution.git_slug, submission.git_slug
    assert_equal solution.git_important_files_hash, submission.git_important_files_hash
  end

  test "correct test_runs are retrieved" do
    exercise_hash = "exercise-hash"
    submission_hash = "submission-hash"

    exercise = create :practice_exercise, git_important_files_hash: exercise_hash
    submission = create :submission, git_important_files_hash: submission_hash, solution: create(:practice_solution, exercise:)

    create :submission_test_run, submission:, git_important_files_hash: SecureRandom.uuid

    # Create two head runs to check we get the latest
    create :submission_test_run, submission:, git_important_files_hash: exercise_hash
    head_run_2 = create :submission_test_run, submission:, git_important_files_hash: exercise_hash

    # Create two submission runs to check we get the latest
    create :submission_test_run, submission:, git_important_files_hash: submission_hash
    submission_run_2 = create :submission_test_run, submission:, git_important_files_hash: submission_hash
    create :submission_test_run, submission:, git_important_files_hash: SecureRandom.uuid

    # Sanity
    assert_equal exercise_hash, exercise.git_important_files_hash
    assert_equal exercise_hash, head_run_2.git_important_files_hash
    assert_equal submission_hash, submission.git_important_files_hash
    assert_equal submission_hash, submission_run_2.git_important_files_hash

    assert_equal 6, submission.test_runs.size
    assert_equal head_run_2, submission.head_test_run
    assert_equal submission_run_2, submission.test_run
  end

  test "submission_representation" do
    ast = "foobar"

    # No submission_representation
    submission = create :submission
    assert_nil submission.exercise_representation

    # Ops error submission rep
    sr = create :submission_representation, submission:, ast:, ops_status: 500
    submission = Submission.find(submission.id)
    assert_nil submission.exercise_representation

    # Missing exercise_representation
    sr.update!(ops_status: 200)
    submission = Submission.find(submission.id)
    assert_nil submission.exercise_representation

    # exercise_representation present
    er = create :exercise_representation, exercise: submission.exercise, ast_digest: sr.ast_digest
    submission = Submission.find(submission.id)
    assert_equal er, submission.exercise_representation

    # another exercise_representation present
    another_ast = "baz"
    another_sr = create :submission_representation, submission:, ast: another_ast, ops_status: 200
    another_er = create :exercise_representation, exercise: submission.exercise, ast_digest: another_sr.ast_digest
    submission = Submission.find(submission.id)
    assert_equal another_er, submission.exercise_representation
  end

  test "exercise_representation" do
    ast = "foobar"

    # No submission_representation
    submission = create :submission
    assert_nil submission.exercise_representation

    # Ops error submission rep
    sr = create :submission_representation, submission:, ast:, ops_status: 500
    submission = Submission.find(submission.id)
    assert_nil submission.exercise_representation

    # Missing exercise_representation
    sr.update!(ops_status: 200)
    submission = Submission.find(submission.id)
    assert_nil submission.exercise_representation

    # exercise_representation present
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

    create(:submission_representation, ast_digest: "foobar", submission:)
    er = create :exercise_representation, ast_digest: "foobar", exercise: submission.exercise
    assert Submission.find(submission.id).automated_feedback_pending?

    er.update!(feedback_markdown: "foobar", feedback_author: create(:user), feedback_type: :non_actionable)
    submission = Submission.find(submission.id)
    assert submission.automated_feedback_pending?
    refute submission.has_essential_automated_feedback?
    refute submission.has_actionable_automated_feedback?
    assert submission.has_non_actionable_automated_feedback?

    er.update!(feedback_type: :actionable)
    submission = Submission.find(submission.id)
    assert submission.automated_feedback_pending?
    refute submission.has_essential_automated_feedback?
    assert submission.has_actionable_automated_feedback?
    refute submission.has_non_actionable_automated_feedback?

    er.update!(feedback_type: :essential)
    submission = Submission.find(submission.id)
    assert submission.automated_feedback_pending?
    assert submission.has_essential_automated_feedback?
    refute submission.has_actionable_automated_feedback?
    refute submission.has_celebratory_automated_feedback?
    refute submission.has_non_actionable_automated_feedback?

    er.update!(feedback_type: :celebratory)
    submission = Submission.find(submission.id)
    assert submission.automated_feedback_pending?
    refute submission.has_essential_automated_feedback?
    refute submission.has_actionable_automated_feedback?
    assert submission.has_celebratory_automated_feedback?
    refute submission.has_non_actionable_automated_feedback?

    # Present only if there is actual feedback on analysis
    submission = create :submission, representation_status: :queued, analysis_status: :completed
    assert submission.automated_feedback_pending?

    sa = create(:submission_analysis, submission:)
    assert Submission.find(submission.id).automated_feedback_pending?

    sa.update(data: { comments: ['asd'] })
    submission = Submission.find(submission.id)
    assert submission.automated_feedback_pending?
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

  test "automated_feedback_pending for track without analyzer" do
    # Pending without queued
    submission = create :submission, representation_status: :generated, analysis_status: :not_queued
    submission.track.update!(has_analyzer: true)
    assert submission.automated_feedback_pending?

    # Pending with queued
    submission = create :submission, representation_status: :generated, analysis_status: :queued
    submission.track.update!(has_analyzer: true)
    assert submission.automated_feedback_pending?

    # Present only if there is actual feedback on analysis
    submission = create :submission, representation_status: :generated, analysis_status: :completed
    submission.track.update!(has_analyzer: true)
    refute submission.automated_feedback_pending?

    sa = create(:submission_analysis, submission:)
    refute Submission.find(submission.id).automated_feedback_pending?

    sa.update(data: { comments: ['asd'] })
    submission = Submission.find(submission.id)
    refute submission.automated_feedback_pending?
    assert submission.has_automated_feedback?

    # Check if completed but without have feedback
    submission = create :submission, representation_status: :generated, analysis_status: :completed
    submission.track.update!(has_analyzer: true)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?

    # Check exceptioned state
    submission = create :submission, representation_status: :generated, analysis_status: :exceptioned
    submission.track.update!(has_analyzer: true)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?

    # Check cancelled state
    submission = create :submission, representation_status: :generated, analysis_status: :cancelled
    submission.track.update!(has_analyzer: true)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?
  end

  test "automated_feedback_pending for track without representer" do
    # Pending without queued
    submission = create :submission, representation_status: :not_queued, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    refute submission.automated_feedback_pending?

    # Pending with queued
    submission = create :submission, representation_status: :queued, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    assert submission.automated_feedback_pending?

    # Present only if there is actual feedback on representation
    submission = create :submission, representation_status: :generated, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    refute submission.automated_feedback_pending?

    create(:submission_representation, ast_digest: "foobar", submission:)
    er = create :exercise_representation, ast_digest: "foobar", exercise: submission.exercise
    refute Submission.find(submission.id).automated_feedback_pending?

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

    # Check if completed but without feedback
    submission = create :submission, representation_status: :generated, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?

    # Check exceptioned state
    submission = create :submission, representation_status: :exceptioned, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?

    # Check cancelled state
    submission = create :submission, representation_status: :cancelled, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?
  end

  test "automated_feedback_pending for track without representer nor analyzer" do
    submission = create :submission, representation_status: :not_queued, analysis_status: :not_queued
    submission.track.update!(has_analyzer: false)
    refute submission.automated_feedback_pending?
    refute submission.has_automated_feedback?
  end

  test "representer_feedback is correctly nil" do
    submission = create :submission, representation_status: :generated
    assert_nil submission.representer_feedback

    create(:submission_representation, ast_digest: "foobar", submission:)
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

    sa = create(:submission_analysis, submission:)
    submission = Submission.find(submission.id)
    assert_nil submission.reload.analyzer_feedback

    sa.update(data: { comments: ['asd'] })
    submission = Submission.find(submission.id)
    assert submission.reload.analyzer_feedback
  end

  test "representer_feedback is populated correctly" do
    reputation = 50
    author = create(:user, reputation:)
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, representation_status: :generated
    create(:submission_representation, ast_digest:, submission:)
    create :exercise_representation, ast_digest:, exercise: submission.exercise,
      feedback_markdown: markdown, feedback_author: author, feedback_type: :essential

    expected = {
      html: "<p>foobar</p>\n",
      author: {
        name: author.name,
        reputation: 50,
        flair: author.flair,
        avatar_url: author.avatar_url,
        profile_url: nil
      },
      editor: nil
    }
    assert_equal expected, submission.representer_feedback
  end

  test "representer_feedback with editor" do
    reputation = 50
    author = create(:user, reputation:)
    editor = create :user, reputation: 33
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, representation_status: :generated
    create(:submission_representation, ast_digest:, submission:)
    exercise_representation = create :exercise_representation, ast_digest:, exercise: submission.exercise,
      feedback_markdown: markdown, feedback_author: author, feedback_type: :essential

    assert_nil submission.representer_feedback[:editor]

    exercise_representation.update(feedback_editor: editor)
    expected = {
      html: "<p>foobar</p>\n",
      author: {
        name: author.name,
        reputation: 50,
        flair: author.flair,
        avatar_url: author.avatar_url,
        profile_url: nil
      },
      editor: {
        name: editor.name,
        reputation: editor.reputation,
        flair: editor.flair,
        avatar_url: editor.avatar_url,
        profile_url: nil
      }
    }
    assert_equal expected, submission.reload.representer_feedback
  end

  test "analyzer_feedback is populated correctly" do
    TestHelpers.use_website_copy_test_repo!

    reputation = 50
    author = create(:user, reputation:)
    markdown = "foobar"
    ast_digest = "digest"
    submission = create :submission, analysis_status: :completed
    create :submission_analysis, submission:, data: {
      summary: "Some summary",
      comments: ["ruby.two-fer.incorrect_default_param"]
    }
    create :exercise_representation, ast_digest:, exercise: submission.exercise,
      feedback_markdown: markdown, feedback_author: author

    expected = {
      summary: "Some summary",
      comments: [
        {
          type: :informative,
          html: "<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>\n"
        }
      ]
    }
    assert_equal expected, submission.analyzer_feedback
  end

  test "viewable_by pivots correctly" do
    admin = create :user, :admin
    student = create :user
    mentor_1 = create :user
    mentor_2 = create :user
    user = create :user, :not_mentor

    solution = create :concept_solution, user: student
    submission = create(:submission, solution:)
    iteration = create(:iteration, solution:, submission:)
    other_iteration = create(:iteration, solution:)

    assert submission.viewable_by?(admin)
    assert submission.viewable_by?(student)
    refute submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    create(:mentor_discussion, mentor: mentor_1, solution:)
    assert submission.viewable_by?(admin)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    create :mentor_request, solution:, status: :fulfilled
    assert submission.viewable_by?(admin)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    refute submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    create :mentor_request, solution:, status: :pending
    assert submission.viewable_by?(admin)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    solution.update(published_at: Time.current)
    assert submission.viewable_by?(admin)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    assert submission.viewable_by?(user)
    assert submission.viewable_by?(nil)

    solution.update(published_iteration: other_iteration)
    assert submission.viewable_by?(admin)
    assert submission.viewable_by?(student)
    assert submission.viewable_by?(mentor_1)
    assert submission.viewable_by?(mentor_2)
    refute submission.viewable_by?(user)
    refute submission.viewable_by?(nil)

    solution.update(published_iteration: iteration)
    assert submission.viewable_by?(admin)
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
    submission_1 = create(:submission, solution:)
    submission_2 = create(:submission, solution:)
    iteration = create(:iteration, submission: submission_1, solution:)
    create(:mentor_discussion, mentor: mentor_1, solution:)
    create(:mentor_request, solution:)

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
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow .meta
    create :submission_file, submission:, filename: ".docs/something.md" # Don't allow .docs
    create :submission_file, submission:, filename: ".exercism/config.json" # Don't allow .exercism

    assert_equal ["log_line_parser.rb", "subdir/new_file.rb"], submission.valid_filepaths
  end

  # The "d" track has both source and tests in the same file.
  # The config tells us this by having solution and test be the same
  test "valid_filepaths when test is same as solution file" do
    exercise = create :practice_exercise, slug: "d-like"
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)

    create :submission_file, submission:, filename: "source/bob.d"

    # Sanity
    repo = Git::Exercise.for_solution(solution)
    assert_equal repo.solution_filepaths, repo.test_filepaths

    # Check the file is allowed
    assert_equal ["source/bob.d"], submission.valid_filepaths
  end

  test "exercise_files" do
    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Exclude solution file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Exclude new file
    create :submission_file, submission:, filename: "log_line_parser_test.rb" # Include tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Include .meta files
    create :submission_file, submission:, filename: ".docs/something.md" # Exclude .docs
    create :submission_file, submission:, filename: ".exercism/config.json" # Exclude .exercism

    expected = {
      ".meta/config.json" => "{\n  \"blurb\": \"Like puppets on a...\",\n  \"authors\": [\"pvcarrera\"],\n  \"files\": {\n    \"solution\": [\"log_line_parser.rb\"],\n    \"test\": [\"log_line_parser_test.rb\"],\n    \"exemplar\": [\".meta/exemplar.rb\"]\n  }\n}\n", # rubocop:disable Layout/LineLength
      ".meta/design.md" => "## Goal\n\nThe goal of this exercise is to teach the student the basics of the Concept of Strings in [Ruby][ruby-doc.org-string].\n\n## Learning objectives\n\n- Know of the existence of the `String` object.\n- Know how to create a string.\n- Know of some basic string methods (like finding the index of a character at a position, or returning a part the string).\n- Know how to do basic string interpolation.\n\n## Out of scope\n\n- Using standard or custom format strings.\n- Memory and performance characteristics.\n- Strings can be a collection.\n\n## Concepts\n\nThe Concepts this exercise unlocks are:\n\n- `strings-basic`: know of the existence of the `String` object; know of some basic functions (like looking up a character at a position, or slicing the string); know how to do basic string interpolation.\n\n## Prerequisites\n\nThere are no prerequisites.\n\n## Representer\n\nThis exercise does not require any specific representation logic to be added to the [representer][representer].\n\n## Analyzer\n\nThis exercise does not require any specific logic to be added to the [analyzer][analyzer].\n\n[analyzer]: https://github.com/exercism/ruby-analyzer\n[representer]: https://github.com/exercism/ruby-representer\n[ruby-doc.org-string]: https://ruby-doc.org/core-2.7.0/String.html\n", # rubocop:disable Layout/LineLength
      ".meta/exemplar.rb" => "# frozen_string_literal: true\n\nmodule LogLineParser\n  def self.message(line)\n    line.slice(line.index(':') + 1, line.size).strip\n  end\n\n  def self.log_level(line)\n    line.slice(1, line.index(']') - 1).downcase\n  end\n\n  def self.reformat(line)\n    \"\#{self.message(line)} (\#{self.log_level(line)})\"\n  end\nend\n", # rubocop:disable Layout/LineLength
      "log_line_parser_test.rb" => "# frozen_string_literal: true\n\nrequire 'minitest/autorun'\nrequire_relative 'log_line_parser'\n\nclass LogLineParserTest < Minitest::Test\n  def test_error_message\n    assert_equal 'Stack overflow', LogLineParser.message('[ERROR]: Stack overflow')\n  end\n\n  def test_warning_message\n    assert_equal 'Disk almost full', LogLineParser.message('[WARNING]: Disk almost full')\n  end\n\n  def test_info_message\n    assert_equal 'File moved', LogLineParser.message('[INFO]: File moved')\n  end\n\n  def test_message_with_leading_and_trailing_space\n    assert_equal 'Timezone not set', LogLineParser.message(\"[WARNING]:   \\tTimezone not set  \\r\\n\")\n  end\n\n  def test_error_log_level\n    assert_equal 'error', LogLineParser.log_level('[ERROR]: Disk full')\n  end\n\n  def test_warning_log_level\n    assert_equal 'warning', LogLineParser.log_level('[WARNING]: Unsafe password')\n  end\n\n  def test_info_log_level\n    assert_equal 'info', LogLineParser.log_level('[INFO]: Timezone changed')\n  end\n\n  def test_erro_reformat\n    assert_equal 'Segmentation fault (error)', LogLineParser.reformat('[ERROR]: Segmentation fault')\n  end\n\n  def test_warning_reformat\n    assert_equal 'Decreased performance (warning)', LogLineParser.reformat('[WARNING]: Decreased performance')\n  end\n\n  def test_info_reformat\n    assert_equal 'Disk defragmented (info)', LogLineParser.reformat('[INFO]: Disk defragmented')\n  end\n\n  def rest_reformat_with_leading_and_trailing_space\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\n\n  def test_new_test_for_diffs\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\nend\n" # rubocop:disable Layout/LineLength
    }
    assert_equal expected, submission.exercise_files
  end

  # The "d" track has both source and tests in the same file.
  # The config tells us this by having solution and test be the same
  test "exercise_files when test is same as solution file" do
    exercise = create :practice_exercise, slug: "d-like"
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)

    create :submission_file, submission:, filename: "source/bob.d"

    # Sanity
    repo = Git::Exercise.for_solution(solution)
    assert_equal repo.solution_filepaths, repo.test_filepaths

    # Check the file is allowed
    refute_includes submission.exercise_files, "source/bob.d"
  end

  test "track: inferred from solution" do
    solution = create :practice_solution
    submission = create(:submission, solution:)

    assert_equal solution.track, submission.track
  end

  test "exercise: inferred from solution's exercise" do
    solution = create :practice_solution
    submission = create(:submission, solution:)

    assert_equal solution.exercise, submission.exercise
  end

  test "tagged and untagged scopes" do
    tagged = create(:submission, tags: ["construct:if"])
    untagged = create(:submission, tags: nil)

    assert_equal [tagged], Submission.tagged
    assert_equal [untagged], Submission.untagged
  end

  test "has_iteration scope" do
    has_iteration = create(:submission, iteration: create(:iteration))
    create(:submission, iteration: nil)

    assert_equal [has_iteration], Submission.has_iteration
  end
end
