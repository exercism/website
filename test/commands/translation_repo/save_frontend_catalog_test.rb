require "test_helper"

class TranslationRepo::SaveFrontendCatalogTest < ActiveSupport::TestCase
  setup { setup_s3_cache_bucket! }

  test "saves the current catalog under its hash, byte for byte" do
    with_published_translations(hu: { frontend: { ns: { a: "é" } } }) do
      bytes = File.binread(TranslationRepo.frontend_catalog_path(:hu))
      hash = TranslationRepo.catalog_hash(bytes)

      TranslationRepo::SaveFrontendCatalog.("hu", hash)

      stored = download_s3_file(Exercism.config.aws_cache_bucket, "i18n/frontend/hu/#{hash}.json")
      assert_equal bytes.b, stored.b
      assert_equal hash, TranslationRepo.catalog_hash(stored)
    end
  end

  test "skips the save when a copy already exists" do
    with_published_translations(hu: { frontend: { ns: { a: "b" } } }) do
      hash = TranslationRepo.frontend_catalog_hash(:hu)
      upload_to_s3(Exercism.config.aws_cache_bucket, "i18n/frontend/hu/#{hash}.json", "existing")

      TranslationRepo::SaveFrontendCatalog.("hu", hash)

      assert_equal "existing", download_s3_file(Exercism.config.aws_cache_bucket, "i18n/frontend/hu/#{hash}.json")
    end
  end

  test "saves nothing if the catalog has changed since the hash was calculated" do
    with_published_translations(hu: { frontend: { ns: { a: "b" } } }) do
      TranslationRepo::SaveFrontendCatalog.("hu", "cccccccccccc")

      assert_raises(Aws::S3::Errors::NoSuchKey) do
        download_s3_file(Exercism.config.aws_cache_bucket, "i18n/frontend/hu/cccccccccccc.json")
      end
    end
  end

  test "swallows S3 errors" do
    Exercism.stubs(:s3_client).raises(RuntimeError, "s3 is down")

    assert_nil TranslationRepo::SaveFrontendCatalog.("hu", "cccccccccccc")
  end
end
