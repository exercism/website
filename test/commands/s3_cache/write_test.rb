require 'test_helper'

class S3Cache::WriteTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "writes data as JSON" do
    S3Cache::Write.("test/write/data.json", { foo: "bar" })

    assert_equal(
      { foo: "bar" }.to_json,
      download_s3_file(Exercism.config.aws_cache_bucket, "test/write/data.json")
    )
  end

  test "swallows S3 errors" do
    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_nil S3Cache::Write.("test/write/error.json", { foo: "bar" })
  end
end
