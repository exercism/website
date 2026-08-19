# Writes a JSON payload to the S3 cache bucket.
# Failures are swallowed: a cache that fails to fill just means the
# next read misses and regenerates. Usually invoked via .defer so the
# write happens off the request path.
class S3Cache::Write
  include Mandate

  queue_as :background

  initialize_with :key, :data

  def call
    Exercism.s3_client.put_object(
      bucket: Exercism.config.aws_cache_bucket,
      key:,
      body: data.to_json,
      acl: 'private'
    )
  rescue StandardError
    nil
  end
end
