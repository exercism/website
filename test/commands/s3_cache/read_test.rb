require 'test_helper'

class S3Cache::ReadTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "returns parsed data with symbolized keys" do
    upload_to_s3(Exercism.config.aws_cache_bucket, "test/read/hit.json", { "foo" => "bar", "num" => 5 }.to_json)

    assert_equal({ foo: "bar", num: 5 }, S3Cache::Read.("test/read/hit.json"))
  end

  test "returns nil for a missing key" do
    assert_nil S3Cache::Read.("test/read/missing.json")
  end

  test "returns nil on any S3 error" do
    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_nil S3Cache::Read.("test/read/error.json")
  end

  test "returns nil for invalid JSON" do
    upload_to_s3(Exercism.config.aws_cache_bucket, "test/read/invalid.json", "not-json{")

    assert_nil S3Cache::Read.("test/read/invalid.json")
  end
end
