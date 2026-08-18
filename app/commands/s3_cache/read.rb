# Reads a JSON payload from the S3 cache bucket.
# Returns the parsed data, or nil on a cache miss or any S3 error.
# Callers must always be able to fall back to generating the data live.
class S3Cache::Read
  include Mandate

  initialize_with :key

  def call
    JSON.parse(raw, symbolize_names: true)
  rescue StandardError
    nil
  end

  private
  def raw
    Exercism.s3_client.get_object(
      bucket: Exercism.config.aws_cache_bucket,
      key:
    ).body.read
  end
end
