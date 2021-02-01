require 'test_helper'

class Submission::Analysis::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    exercise_repo = Git::Exercise.for_solution(solution)
    submission = create :submission, solution: solution

    ToolingJob::Create.expects(:call).with(
      :analyzer,
      submission_uuid: submission.uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug,
      source: {
        submission_efs_root: submission.uuid,
        submission_filepaths: [],
        exercise_git_repo: "ruby",
        exercise_git_sha: exercise_repo.normalised_git_sha,
        exercise_git_dir: exercise_repo.dir,
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/example.rb"]
      }
    )
    Submission::Analysis::Init.(submission)
  end
end
