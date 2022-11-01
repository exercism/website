class Track::UpdateBuildStatus
  include Mandate

  initialize_with :track

  def call
    Exercism.redis_tooling_client.set(track.build_status_key, build_status)
  end

  private
  def build_status
    {}
  end
end
