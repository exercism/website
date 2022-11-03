module Track::BuildStatus
  extend Mandate::Memoize

  memoize
  def build_status
    redis_value = redis.get(build_status_key)
    return nil if redis_value.blank?

    JSON.parse(redis_value, symbolize_names: true)
  end

  def build_status=(value)
    redis.set(build_status_key, value.to_json)
  end

  private
  def build_status_key = "build_status:#{id}"

  memoize
  def redis = Exercism.redis_tooling_client
end
