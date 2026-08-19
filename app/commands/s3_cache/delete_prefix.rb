# Deletes every object under a prefix in the S3 cache bucket, except
# except_key (the current version, which a concurrent write may just
# have created and must survive the invalidation).
# This is belt-and-braces invalidation: cache keys are versioned so a
# missed delete never serves stale data, it just leaves orphans behind.
# Failures are therefore swallowed.
class S3Cache::DeletePrefix
  include Mandate

  queue_as :background

  initialize_with :prefix, except_key: nil

  def call
    loop do
      keys = list_keys
      deletable = keys - [except_key]
      delete!(deletable) if deletable.any?
      break if keys.size < BATCH_SIZE
    end
  rescue StandardError
    nil
  end

  private
  def list_keys
    Exercism.s3_client.list_objects_v2(
      bucket:,
      prefix:,
      max_keys: BATCH_SIZE
    ).contents.map(&:key)
  end

  def delete!(keys)
    Exercism.s3_client.delete_objects(
      bucket:,
      delete: { objects: keys.map { |key| { key: } } }
    )
  end

  def bucket = Exercism.config.aws_cache_bucket

  BATCH_SIZE = 1000
end
