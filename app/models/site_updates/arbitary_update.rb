# SiteUpdates::ArbitaryUpdate.create!(track: Track.find('csharp'),
# title: "Some title", description: "Some description", author: User.first, published_at: Time.now)

class SiteUpdates::ArbitaryUpdate < SiteUpdate
  def guard_params = "Random##{SecureRandom.uuid}"

  def i18n_params
    {
      author_handle: author.handle
    }
  end

  def icon
    {
      type: :image,
      url: track.icon_url
    }
  end
end
