require 'test_helper'

class Concept::CachedContent::StoreTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "writes the generated payload to the sharded sha-versioned key" do
    concept = create :concept

    Concept::CachedContent::Store.(concept)

    uuid = concept.uuid
    key = "concept-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{concept.synced_to_git_sha}.json"

    expected = JSON.parse(Concept::CachedContent::Generate.(concept).to_json, symbolize_names: true)
    assert_equal expected, S3Cache::Read.(key)
  end
end
