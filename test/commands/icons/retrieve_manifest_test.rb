require 'test_helper'

class Icons::RetrieveManifestTest < ActiveSupport::TestCase
  test "retrieves and caches the manifest" do
    setup_s3_icons_manifest!(["exercises/bob.svg", "tracks/ruby.svg"])

    assert_equal Set["exercises/bob.svg", "tracks/ruby.svg"], Icons::RetrieveManifest.()

    # The second call should come from the cache, not the bucket
    setup_s3_icons_manifest!(["exercises/leap.svg"])
    assert_equal Set["exercises/bob.svg", "tracks/ruby.svg"], Icons::RetrieveManifest.()
  end

  test "returns an empty set when there's no manifest" do
    assert_empty Icons::RetrieveManifest.()
  end

  test "returns an empty set when the manifest isn't an array" do
    setup_s3_icons_manifest!({ exercises: [] })

    assert_empty Icons::RetrieveManifest.()
  end

  test "retries sooner after a failure" do
    assert_empty Icons::RetrieveManifest.()

    travel 2.minutes do
      setup_s3_icons_manifest!(["exercises/bob.svg"])
      assert_equal Set["exercises/bob.svg"], Icons::RetrieveManifest.()
    end
  end

  test "keeps the manifest in the process" do
    setup_s3_icons_manifest!(["exercises/bob.svg"])
    Icons::RetrieveManifest.()

    Rails.cache.expects(:read).never
    assert_equal Set["exercises/bob.svg"], Icons::RetrieveManifest.()
  end

  test "reads the shared cache again after an hour" do
    setup_s3_icons_manifest!(["exercises/bob.svg"])
    Icons::RetrieveManifest.()
    Rails.cache.write("Icons::RetrieveManifest", Set["exercises/leap.svg"])

    travel 61.minutes do
      assert_equal Set["exercises/leap.svg"], Icons::RetrieveManifest.()
    end
  end
end
