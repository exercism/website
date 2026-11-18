# Returns the bytes of an earlier version of a locale's frontend catalog from the
# S3 cache bucket, or nil if there is no copy or S3 fails. SaveFrontendCatalog
# checks the hash before it saves a copy.
class TranslationRepo::RetrieveStoredFrontendCatalog
  include Mandate

  initialize_with :locale, :catalog_hash

  def call
    Exercism.s3_client.get_object(
      bucket: Exercism.config.aws_cache_bucket,
      key: TranslationRepo.frontend_catalog_s3_key(locale, catalog_hash)
    ).body.read
  rescue StandardError
    nil
  end
end
