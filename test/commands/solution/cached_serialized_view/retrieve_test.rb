require 'test_helper'

class Solution::CachedSerializedView::RetrieveTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "cache hit returns the stored payload without deferring a write" do
    solution = create(:practice_solution, :published)
    upload_to_s3(Exercism.config.aws_cache_bucket, cache_key_for(solution),
      { iterations: [], language: "cached" }.to_json)

    S3Cache::Write.expects(:defer).never

    assert_equal(
      { iterations: [], language: "cached" },
      Solution::CachedSerializedView::Retrieve.(solution)
    )
  end

  test "cache miss generates live and defers a write" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    S3Cache::Write.expects(:defer).with(cache_key_for(solution), anything)

    payload = Solution::CachedSerializedView::Retrieve.(solution)

    assert_equal Solution::CachedSerializedView::Generate.(solution), payload
    assert_equal solution.track.highlightjs_language, payload[:language]
  end

  test "cache miss serializes once, handing the generated payload to the write" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)
    generated = { iterations: [], language: "generated-once" }

    Solution::CachedSerializedView::Generate.expects(:call).with(solution).once.returns(generated)
    S3Cache::Write.expects(:defer).with(cache_key_for(solution), generated)

    assert_equal generated, Solution::CachedSerializedView::Retrieve.(solution)
  end

  test "write is keyed on the version that was serialized, not a later one" do
    solution = create(:practice_solution, :published)
    key_at_read_time = cache_key_for(solution)

    S3Cache::Write.expects(:defer).with(key_at_read_time, anything)
    Solution::CachedSerializedView::Retrieve.(solution)

    # Had the key been recomputed when the deferred job ran, a solution
    # changing in the meantime would have filed this payload under the new
    # version's key, where it would be read back as current.
    solution.update!(updated_at: solution.updated_at + 1.hour)
    refute_equal key_at_read_time, cache_key_for(solution.reload)
  end

  test "an old version's cache entry is not read after the solution changes" do
    solution = create(:practice_solution, :published)
    upload_to_s3(Exercism.config.aws_cache_bucket, cache_key_for(solution),
      { language: "stale" }.to_json)

    solution.update!(updated_at: solution.updated_at + 1.hour)
    S3Cache::Write.expects(:defer).with(cache_key_for(solution), anything)

    payload = Solution::CachedSerializedView::Retrieve.(solution)

    refute_equal "stale", payload[:language]
  end

  test "falls back to live generation on S3 failure" do
    solution = create(:practice_solution, :published)

    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_equal(
      Solution::CachedSerializedView::Generate.(solution),
      Solution::CachedSerializedView::Retrieve.(solution)
    )
  end

  test "a cache miss in another locale returns what generating in that locale returns" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    with_available_locales(:hu) do
      english = Solution::CachedSerializedView::Generate.(solution)
      expected = I18n.with_locale(:hu) { Solution::CachedSerializedView::Generate.(solution) }
      refute_equal english, expected, "the payload does not vary by locale, so this test proves nothing"

      I18n.with_locale(:hu) do
        assert_equal expected, Solution::CachedSerializedView::Retrieve.(solution)
      end
    end
  end

  test "a cache hit in another locale returns what generating in that locale returns" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)
    upload_to_s3(Exercism.config.aws_cache_bucket, cache_key_for(solution),
      Solution::CachedSerializedView::Generate.(solution).to_json)

    with_available_locales(:hu) do
      expected = I18n.with_locale(:hu) { Solution::CachedSerializedView::Generate.(solution) }

      I18n.with_locale(:hu) do
        S3Cache::Write.expects(:defer).never

        assert_equal expected, Solution::CachedSerializedView::Retrieve.(solution)
      end
    end
  end

  test "two locales share one cache entry, keyed without a locale" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    with_available_locales(:hu) do
      perform_enqueued_jobs do
        I18n.with_locale(:hu) { Solution::CachedSerializedView::Retrieve.(solution) }
        Solution::CachedSerializedView::Retrieve.(solution)
      end
    end

    assert_equal [cache_key_for(solution)], cached_keys_for(solution)
  end

  test "the cached entry holds the default locale's payload, whichever locale filled it" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    with_available_locales(:hu) do
      perform_enqueued_jobs do
        I18n.with_locale(:hu) { Solution::CachedSerializedView::Retrieve.(solution) }
      end
    end

    assert_equal(
      Solution::CachedSerializedView::Generate.(solution),
      JSON.parse(download_s3_file(Exercism.config.aws_cache_bucket, cache_key_for(solution)), symbolize_names: true)
    )
  end

  private
  def cache_key_for(solution)
    uuid = solution.uuid
    "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{solution.updated_at.to_i}.json"
  end

  def cached_keys_for(solution)
    uuid = solution.uuid
    Exercism.s3_client.list_objects_v2(
      bucket: Exercism.config.aws_cache_bucket,
      prefix: "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/"
    ).contents.map(&:key)
  end
end
