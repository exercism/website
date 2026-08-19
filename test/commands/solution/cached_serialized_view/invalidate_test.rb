require 'test_helper'

class Solution::CachedSerializedView::InvalidateTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "deletes all cached versions for the solution only" do
    solution = create(:practice_solution, :published)
    other_solution = create(:practice_solution, :published)

    bucket = Exercism.config.aws_cache_bucket
    uuid = solution.uuid
    prefix = "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/"
    other_uuid = other_solution.uuid
    other_key = "solution-view/#{other_uuid[0, 2]}/#{other_uuid[2, 2]}/#{other_uuid}/123.json"

    current_key = "#{prefix}#{solution.updated_at.to_i}.json"

    upload_to_s3(bucket, "#{prefix}100.json", "{}")
    upload_to_s3(bucket, "#{prefix}200.json", "{}")
    upload_to_s3(bucket, current_key, "{}")
    upload_to_s3(bucket, other_key, "{}")

    Solution::CachedSerializedView::Invalidate.(solution)

    assert_nil S3Cache::Read.("#{prefix}100.json")
    assert_nil S3Cache::Read.("#{prefix}200.json")
    assert_empty(S3Cache::Read.(current_key))
    assert_empty(S3Cache::Read.(other_key))
  end

  test "is deferred from Solution::InvalidateCloudflareCache" do
    solution = create :practice_solution

    Cloudflare::PurgeUrls.stubs(:call)
    Solution::CachedSerializedView::Invalidate.expects(:defer).with(solution)

    Solution::InvalidateCloudflareCache.(solution)
  end
end
