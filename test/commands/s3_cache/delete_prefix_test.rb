require 'test_helper'

class S3Cache::DeletePrefixTest < ActiveSupport::TestCase
  setup do
    setup_s3_cache_bucket!
  end

  test "deletes all objects under the prefix and nothing else" do
    bucket = Exercism.config.aws_cache_bucket
    upload_to_s3(bucket, "test/delete/target/1.json", "{}")
    upload_to_s3(bucket, "test/delete/target/2.json", "{}")
    upload_to_s3(bucket, "test/delete/other/1.json", "{}")

    S3Cache::DeletePrefix.("test/delete/target/")

    assert_nil S3Cache::Read.("test/delete/target/1.json")
    assert_nil S3Cache::Read.("test/delete/target/2.json")
    assert_empty(S3Cache::Read.("test/delete/other/1.json"))
  end

  test "no-ops on an empty prefix" do
    S3Cache::DeletePrefix.("test/delete/empty/")
  end

  test "swallows S3 errors" do
    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_nil S3Cache::DeletePrefix.("test/delete/error/")
  end
end
