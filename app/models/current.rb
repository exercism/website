class Current < ActiveSupport::CurrentAttributes
  attribute :user_tracks
  attribute :request_id, :user_agent, :ip_address

  def user_track_for(user_param, track_param)
    self.user_tracks ||= {}
    self.user_tracks[[user_param, track_param]] ||= yield
  end
end
