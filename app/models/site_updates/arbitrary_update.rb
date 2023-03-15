class SiteUpdates::ArbitraryUpdate < SiteUpdate
  def guard_params = "Random##{SecureRandom.uuid}"
  def i18n_params = { author_handle: author.handle }
  def icon = { type: :image, url: track.icon_url }
end
