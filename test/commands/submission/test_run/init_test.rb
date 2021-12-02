require 'test_helper'

class Submission::TestRun::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission: submission, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission: submission, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission: submission, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission: submission, filename: ".meta/config.json" # Don't allow meta

    ToolingJob::Create.expects(:call).with(
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
        # Check we exclude .docs, README and the overriden source file
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb", "log_line_parser_test.rb"]
      },
      test_run_type: :submission
    )

    Submission::TestRun::Init.(submission)
  end
end
