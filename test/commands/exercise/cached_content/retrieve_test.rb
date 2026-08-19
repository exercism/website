require 'test_helper'

class Exercise::CachedContent::RetrieveTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "cache hit returns the stored payload without deferring a write" do
    exercise = create :practice_exercise
    key = cache_key(exercise, exercise.git_sha)
    upload_to_s3(
      Exercism.config.aws_cache_bucket, key,
      { introduction: "<p>cached intro</p>", instructions: "<p>cached instructions</p>" }.to_json
    )

    Exercise::CachedContent::Store.expects(:defer).never

    assert_equal(
      { introduction: "<p>cached intro</p>", instructions: "<p>cached instructions</p>" },
      Exercise::CachedContent::Retrieve.(exercise, nil)
    )
  end

  test "cache miss generates live and defers a write" do
    exercise = create :practice_exercise

    Exercise::CachedContent::Store.expects(:defer).with(exercise, nil)

    assert_equal(
      Exercise::CachedContent::Generate.(exercise, nil),
      Exercise::CachedContent::Retrieve.(exercise, nil)
    )
  end

  test "a solution reads the key for the sha it is pinned to" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise:, git_sha: OLD_GIT_SHA
    upload_to_s3(
      Exercism.config.aws_cache_bucket, cache_key(exercise, OLD_GIT_SHA),
      { introduction: "", instructions: "<p>pinned</p>" }.to_json
    )

    Exercise::CachedContent::Store.expects(:defer).never

    assert_equal "<p>pinned</p>", Exercise::CachedContent::Retrieve.(exercise, solution)[:instructions]
  end

  test "an up to date solution shares the anonymous entry" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise:, git_sha: exercise.git_sha
    upload_to_s3(
      Exercism.config.aws_cache_bucket, cache_key(exercise, exercise.git_sha),
      { introduction: "", instructions: "<p>shared</p>" }.to_json
    )

    Exercise::CachedContent::Store.expects(:defer).never

    assert_equal "<p>shared</p>", Exercise::CachedContent::Retrieve.(exercise, solution)[:instructions]
  end

  test "an old sha's cache entry is not read after the exercise syncs" do
    exercise = create :practice_exercise
    upload_to_s3(
      Exercism.config.aws_cache_bucket, cache_key(exercise, exercise.git_sha),
      { introduction: "", instructions: "<p>stale</p>" }.to_json
    )

    exercise.update_columns(git_sha: OLD_GIT_SHA)
    Exercise::CachedContent::Store.expects(:defer).with(exercise, nil)

    refute_equal "<p>stale</p>", Exercise::CachedContent::Retrieve.(exercise, nil)[:instructions]
  end

  test "falls back to live generation on S3 failure" do
    exercise = create :practice_exercise
    expected = Exercise::CachedContent::Generate.(exercise, nil)

    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_equal expected, Exercise::CachedContent::Retrieve.(exercise, nil)
  end

  def cache_key(exercise, sha)
    uuid = exercise.uuid
    "exercise-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{sha}.json"
  end

  # A real commit in the test repo, so content can still be read at it.
  OLD_GIT_SHA = '0b04b8976650d993ecf4603cf7413f3c6b898eff'.freeze
end
