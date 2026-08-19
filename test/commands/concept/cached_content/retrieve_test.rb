require 'test_helper'

class Concept::CachedContent::RetrieveTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "cache hit returns the stored payload without deferring a write" do
    concept = create :concept
    upload_to_s3(
      Exercism.config.aws_cache_bucket, cache_key(concept, concept.synced_to_git_sha),
      { about: "<p>cached about</p>", introduction: "<p>cached intro</p>" }.to_json
    )

    Concept::CachedContent::Store.expects(:defer).never

    assert_equal(
      { about: "<p>cached about</p>", introduction: "<p>cached intro</p>" },
      Concept::CachedContent::Retrieve.(concept)
    )
  end

  test "cache miss generates live and defers a write" do
    concept = create :concept

    Concept::CachedContent::Store.expects(:defer).with(concept)

    assert_equal(
      Concept::CachedContent::Generate.(concept),
      Concept::CachedContent::Retrieve.(concept)
    )
  end

  test "an old sha's cache entry is not read after the concept syncs" do
    concept = create :concept
    upload_to_s3(
      Exercism.config.aws_cache_bucket, cache_key(concept, concept.synced_to_git_sha),
      { about: "<p>stale</p>", introduction: "" }.to_json
    )

    concept.update!(synced_to_git_sha: "new-sha")
    Concept::CachedContent::Store.expects(:defer).with(concept)

    refute_equal "<p>stale</p>", Concept::CachedContent::Retrieve.(concept)[:about]
  end

  test "falls back to live generation on S3 failure" do
    concept = create :concept
    expected = Concept::CachedContent::Generate.(concept)

    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_equal expected, Concept::CachedContent::Retrieve.(concept)
  end

  def cache_key(concept, sha)
    uuid = concept.uuid
    "concept-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{sha}.json"
  end
end
