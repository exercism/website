require 'test_helper'

class Submission::Representation::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: "bob.rb" # Override old file
    create :submission_file, submission: submission, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission: submission, filename: "bob_test.rb" # Don't override tests

    ToolingJob::Create.expects(:call).with(
      :representer,
      submission_uuid: submission.uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: ["bob.rb", "subdir/new_file.rb"],
        exercise_git_repo: "v3", # TODO: Monorepo: solution.track.slug,
        exercise_git_sha: "a228a003bae74e24a36bbbd782424d52ac383867",
        exercise_git_dir: "languages/csharp/exercises/concept/datetime",
        # This should only be .meta
        exercise_filepaths: [".meta/config.json"]
      }
    )
    Submission::Representation::Init.(submission)
  end
end
