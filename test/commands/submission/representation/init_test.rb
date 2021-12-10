require 'test_helper'

class Submission::Representation::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission: submission, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission: submission, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission: submission, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission: submission, filename: ".meta/config.json" # Don't allow meta

    ToolingJob::Create.expects(:call).with(
      :representer,
      submission.uuid,
      solution.track.slug,
      solution.exercise.slug,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["log_line_parser.rb", "subdir/new_file.rb"],
        exercise_git_repo: solution.track.slug,
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: "exercises/concept/strings",
        # This should only be .meta
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb"]
      }
    )
    Submission::Representation::Init.(submission)
    assert_equal 'queued', submission.representation_status
  end

  test "calls to publish_message for exercise with editor files" do
    exercise = create :practice_exercise, slug: 'isogram'
    solution = create :practice_solution, exercise: exercise
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: "isogram.rb" # Override old file
    create :submission_file, submission: submission, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission: submission, filename: "isogram_test.rb" # Don't override tests
    create :submission_file, submission: submission, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission: submission, filename: ".meta/config.json" # Don't allow meta

    ToolingJob::Create.expects(:call).with(
      :representer,
      submission.uuid,
      solution.track.slug,
      solution.exercise.slug,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["isogram.rb", "subdir/new_file.rb"],
        exercise_git_repo: solution.track.slug,
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: "exercises/practice/isogram",
        # This should only be .meta
        exercise_filepaths: [".meta/config.json", ".meta/example.rb"]
      }
    )
    Submission::Representation::Init.(submission)
    assert_equal 'queued', submission.representation_status
  end
end
