require 'test_helper'

class Solution::CacheSerializedView::RetrieveTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "cache hit returns the stored payload without deferring a write" do
    solution = create(:practice_solution, :published)
    uuid = solution.uuid
    key = "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{solution.updated_at.to_i}.json"
    upload_to_s3(Exercism.config.aws_cache_bucket, key, { iterations: [], language: "cached" }.to_json)

    Solution::CacheSerializedView::Store.expects(:defer).never

    assert_equal(
      { iterations: [], language: "cached" },
      Solution::CacheSerializedView::Retrieve.(solution)
    )
  end

  test "cache miss generates live and defers a write" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    Solution::CacheSerializedView::Store.expects(:defer).with(solution)

    payload = Solution::CacheSerializedView::Retrieve.(solution)

    assert_equal Solution::CacheSerializedView::Generate.(solution), payload
    assert_equal solution.track.highlightjs_language, payload[:language]
  end

  test "an old version's cache entry is not read after the solution changes" do
    solution = create(:practice_solution, :published)
    uuid = solution.uuid
    old_key = "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{solution.updated_at.to_i}.json"
    upload_to_s3(Exercism.config.aws_cache_bucket, old_key, { language: "stale" }.to_json)

    solution.update!(updated_at: solution.updated_at + 1.hour)
    Solution::CacheSerializedView::Store.expects(:defer).with(solution)

    payload = Solution::CacheSerializedView::Retrieve.(solution)

    refute_equal "stale", payload[:language]
  end

  test "falls back to live generation on S3 failure" do
    solution = create(:practice_solution, :published)

    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_equal(
      Solution::CacheSerializedView::Generate.(solution),
      Solution::CacheSerializedView::Retrieve.(solution)
    )
  end
end
