require 'test_helper'

class Submission::Representation::InitTest < ActiveSupport::TestCase
  test "uses generic representer if the track doesn't have one" do
    submission = create :submission
    submission.track.stubs(has_representer?: false)

    Submission::Representation::GenerateBasic.expects(:defer).with(submission)

    Submission::Representation::Init.(submission)
    assert_equal 'queued', submission.representation_status
  end

  test "calls to publish_message" do
    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow meta

    Exercism::ToolingJob.expects(:create!).with(
      :representer,
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
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb", "log_line_parser_test.rb"]
      },
      context: {}
    )
    Submission::Representation::Init.(submission)
    assert_equal 'queued', submission.representation_status
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
      :representer,
      submission.uuid,
      solution.track.slug,
      solution.exercise.slug,
      run_in_background: true,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["log_line_parser.rb", "subdir/new_file.rb"],
        exercise_git_repo: solution.track.slug,
        exercise_git_sha: "foobar",
        exercise_git_dir: "exercises/concept/strings",
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb", "log_line_parser_test.rb"]
      },
      context: {}
    )
    Submission::Representation::Init.(submission, type: :exercise, git_sha: "foobar", run_in_background: true)
    assert_equal 'not_queued', submission.representation_status
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
      :representer,
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
        exercise_filepaths: [".meta/config.json", ".meta/example.rb", "helper.rb", "isogram_test.rb"]
      },
      context: {}
    )
    Submission::Representation::Init.(submission)
    assert_equal 'queued', submission.representation_status
  end
end
