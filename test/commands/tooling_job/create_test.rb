require 'test_helper'

class ToolingJob::CreateTest < ActiveSupport::TestCase
  test "stores correctly in redis with custom paths" do
    freeze_time do
      exercise = create :practice_exercise
      solution = create(:practice_solution, exercise:)
      submission = create(:submission, solution:)
      git_sha = "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"
      type = "foobars"

      refute_equal submission.git_sha, git_sha # Sanity

      job = ToolingJob::Create.(submission, type, git_sha:, run_in_background: false)

      redis = Exercism.redis_tooling_client
      expected = {
        source: {
          submission_efs_root: submission.uuid,
          submission_filepaths: [],
          exercise_git_repo: "ruby",
          exercise_git_sha: git_sha,
          exercise_git_dir: "exercises/practice/bob",
          exercise_filepaths: [
            ".meta/config.json",
            "README.md",
            "bob.rb",
            "bob_test.rb",
            "ignore.rb",
            "subdir/more_bob.rb"
          ]
        },
        context: {},
        id: job.id,
        submission_uuid: submission.uuid,
        type:,
        language: submission.track.slug,
        exercise: submission.exercise.slug,
        created_at: Time.current.utc.to_i
      }.to_json

      assert_equal expected, redis.get("job:#{job.id}")
      assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_queued, 0)
      assert_equal job.id, redis.get("submission:#{submission.uuid}:#{type}")
    end
  end

  test "defaults to submission data" do
    git_sha = "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"

    exercise = create :practice_exercise
    solution = create :practice_solution, exercise:, git_sha: "something-wrong"
    submission = create(:submission, solution:, git_sha:)

    assert_equal git_sha, submission.git_sha # Sanity

    job = ToolingJob::Create.(submission, :test_runner)

    redis = Exercism.redis_tooling_client
    assert_equal git_sha, JSON.parse(redis.get("job:#{job.id}"))['source']['exercise_git_sha']
  end

  # We're in testing internals territory here, but I think it's best
  # just to check the param is being passed through correctly anyway.
  test "honours run in background" do
    submission = create :submission

    job = ToolingJob::Create.(submission, :test_runner, run_in_background: true)

    redis = Exercism.redis_tooling_client
    refute_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_queued, 0)
    assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_queued_for_background_processing, 0)
  end
end
