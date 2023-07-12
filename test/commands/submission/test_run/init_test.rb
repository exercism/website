require 'test_helper'

class Submission::TestRun::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow meta

    Exercism::ToolingJob.expects(:create!).with(
      :test_runner,
      submission.uuid,
      solution.track.slug,
      solution.exercise.slug,
      run_in_background: false,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["log_line_parser.rb", "subdir/new_file.rb"],
        exercise_git_repo: solution.track.slug,
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: "exercises/concept/strings",
        # Check we exclude .docs and the overriden source file
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb", "log_line_parser_test.rb"]
      },
      context: {}
    )

    Submission::TestRun::Init.(submission)
  end

  test "calls to publish_message honours arguments" do
    skip # TODO: Fix issue with fake git sha

    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow meta

    Exercism::ToolingJob.expects(:create!).with(
      :test_runner,
      submission.uuid,
      solution.track.slug,
      solution.exercise.slug,
      run_in_background: true,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["log_line_parser.rb", "subdir/new_file.rb"],
        exercise_git_repo: solution.track.slug,
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: "exercises/concept/strings",
        # Check we exclude .docs and the overriden source file
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb", "log_line_parser_test.rb"]
      },
      context: {}
    )

    Submission::TestRun::Init.(submission, git_sha: "foobar", run_in_background: true)
  end

  test "calls to publish_message for exercise with editor files" do
    exercise = create :practice_exercise, slug: 'isogram'
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "isogram.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "isogram_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow meta

    Exercism::ToolingJob.expects(:create!).with(
      :test_runner,
      submission.uuid,
      solution.track.slug,
      solution.exercise.slug,
      run_in_background: false,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["isogram.rb", "subdir/new_file.rb"],
        exercise_git_repo: solution.track.slug,
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: "exercises/practice/isogram",
        # Check we exclude .docs and the overriden source file
        exercise_filepaths: [".meta/config.json", ".meta/example.rb", "helper.rb", "isogram_test.rb"]
      },
      context: {}
    )

    Submission::TestRun::Init.(submission)
  end

  test "update statuses" do
    solution = create :concept_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :user_track, user: submission.user, track: submission.track

    Submission::TestRun::Init.(submission)

    solution.reload

    assert submission.tests_queued?
    assert solution.latest_iteration_head_tests_status_queued?
    assert solution.published_iteration_head_tests_status_queued?
  end

  test "does not update statuses for different git sha" do
    # Stub this as we're using a fake git sha
    ToolingJob::Create.stubs(:call)

    solution = create :concept_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :user_track, user: submission.user, track: submission.track

    Submission::TestRun::Init.(submission, git_sha: "123")

    solution.reload

    assert submission.tests_not_queued?
    assert solution.latest_iteration_head_tests_status_not_queued?
    assert solution.published_iteration_head_tests_status_not_queued?
  end

  test "does not touch user_track solution run for both submission types" do
    time = Time.current - 4.months

    solution = create :concept_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    user_track = create :user_track, user: submission.user, track: submission.track, last_touched_at: time

    Submission::TestRun::Init.(submission)

    solution.reload

    assert_equal time.to_i, user_track.reload.last_touched_at.to_i
    assert solution.latest_iteration_head_tests_status_queued?
    assert solution.published_iteration_head_tests_status_queued?
  end

  test "does not change status if solution is not published" do
    time = Time.current - 4.months

    solution = create :concept_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :user_track, user: submission.user, track: submission.track, last_touched_at: time

    Submission::TestRun::Init.(submission)

    solution.reload
    assert solution.latest_iteration_head_tests_status_queued?
    assert solution.published_iteration_head_tests_status_not_queued?
  end

  test "does not change status if solution is not latest" do
    time = Time.current - 4.months

    solution = create :concept_solution, :published
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    create(:iteration, solution:) # Add another iteration afterwards
    solution.update(published_iteration: iteration)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :user_track, user: submission.user, track: submission.track, last_touched_at: time

    Submission::TestRun::Init.(submission)

    solution.reload
    assert solution.latest_iteration_head_tests_status_not_queued?
    assert solution.published_iteration_head_tests_status_queued?
  end
end
