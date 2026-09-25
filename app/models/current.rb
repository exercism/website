class Current < ActiveSupport::CurrentAttributes
  attribute :user_tracks
  attribute :request_id, :user_agent, :ip_address

  # The locale prefix that generated URLs carry, which is separate from the
  # language a page is rendered in. An anonymous visitor on /hu/tracks gets
  # /hu links. A signed-in user always gets unprefixed links, whatever their
  # locale, because their own locale is applied to every unprefixed URL.
  # Outside a request (jobs, the console) it is nil, so URLs are unprefixed.
  attribute :url_locale

  def user_track_for(user_param, track_param)
    self.user_tracks ||= {}
    self.user_tracks[[user_param, track_param]] ||= yield
  end
end
