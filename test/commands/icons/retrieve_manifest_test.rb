require 'test_helper'

class Icons::RetrieveManifestTest < ActiveSupport::TestCase
  test "retrieves and caches the manifest" do
    stub = stub_manifest(["exercises/bob.svg", "tracks/ruby.svg"])

    assert_equal Set["exercises/bob.svg", "tracks/ruby.svg"], Icons::RetrieveManifest.()

    # The second call should come from the cache
    Icons::RetrieveManifest.()
    assert_requested stub, times: 1
  end

  test "returns an empty set when the manifest can't be retrieved" do
    stub_request(:get, MANIFEST_URL).to_return(status: 500)
    Sentry.expects(:capture_exception).once

    assert_empty Icons::RetrieveManifest.()
  end

  test "returns an empty set when the manifest isn't an array" do
    stub_request(:get, MANIFEST_URL).to_return(status: 200, body: { exercises: [] }.to_json)
    Sentry.expects(:capture_exception).once

    assert_empty Icons::RetrieveManifest.()
  end

  test "retries sooner after a failure" do
    stub_request(:get, MANIFEST_URL).to_return(status: 500)
    Sentry.stubs(:capture_exception)

    assert_empty Icons::RetrieveManifest.()

    travel 2.minutes do
      stub_manifest(["exercises/bob.svg"])
      assert_equal Set["exercises/bob.svg"], Icons::RetrieveManifest.()
    end
  end

  MANIFEST_URL = "https://assets.exercism.org/manifest.json".freeze

  def stub_manifest(paths)
    stub_request(:get, MANIFEST_URL).to_return(status: 200, body: paths.to_json)
  end
end
