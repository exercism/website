require 'test_helper'

class Solution::CacheSerializedView::StoreTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "writes the generated payload to the sharded versioned key" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    Solution::CacheSerializedView::Store.(solution)

    uuid = solution.uuid
    key = "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{solution.updated_at.to_i}.json"
    stored = S3Cache::Read.(key)

    expected = JSON.parse(Solution::CacheSerializedView::Generate.(solution).to_json, symbolize_names: true)
    assert_equal expected, stored
  end
end
