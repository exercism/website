require 'test_helper'

class Exercise::CachedContent::StoreTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "writes the generated payload to the sharded sha-versioned key" do
    exercise = create :practice_exercise

    Exercise::CachedContent::Store.(exercise, nil)

    uuid = exercise.uuid
    key = "exercise-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{exercise.git_sha}.json"

    expected = JSON.parse(Exercise::CachedContent::Generate.(exercise, nil).to_json, symbolize_names: true)
    assert_equal expected, S3Cache::Read.(key)
  end

  test "writes to the solution's pinned sha" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise:, git_sha: OLD_GIT_SHA

    Exercise::CachedContent::Store.(exercise, solution)

    uuid = exercise.uuid
    assert S3Cache::Read.("exercise-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{OLD_GIT_SHA}.json")
  end

  # A real commit in the test repo, so content can still be read at it.
  OLD_GIT_SHA = '0b04b8976650d993ecf4603cf7413f3c6b898eff'.freeze
end
