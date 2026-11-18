# Saves one version of a locale's frontend catalog to the S3 cache bucket, under
# its hash, so that pages rendered against that version can still load it after
# the catalog has changed. Nothing is written if a copy is already there.
#
# The current catalog is read from the checkout, and nothing is saved if it has
# changed since the hash was calculated. The file's exact bytes are stored, so the
# stored copy hashes to the same value.
#
# Failures are swallowed: if a save fails, requests for that version are
# redirected to the current catalog until a later save succeeds.
class TranslationRepo::SaveFrontendCatalog
  include Mandate

  queue_as :default

  initialize_with :locale, :catalog_hash

  def call
    key = TranslationRepo.frontend_catalog_s3_key(locale, catalog_hash)
    return if stored?(key)

    return unless body && TranslationRepo.catalog_hash(body) == catalog_hash

    Exercism.s3_client.put_object(
      bucket:,
      key:,
      body:,
      content_type: "application/json",
      acl: "private"
    )
  rescue StandardError
    nil
  end

  private
  def stored?(key)
    Exercism.s3_client.head_object(bucket:, key:)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end

  memoize
  def body
    File.binread(TranslationRepo.frontend_catalog_path(locale))
  rescue Errno::ENOENT
    nil
  end

  def bucket = Exercism.config.aws_cache_bucket
end
