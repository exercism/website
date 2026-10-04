# Serializes the public information shown in a user's profile header,
# for consumers outside the website such as the MCP server.
class SerializeProfileSummary
  include Mandate

  initialize_with :user

  def call
    {
      handle: user.handle,
      name: user.name,
      url: Exercism::Routes.profile_url(user),
      avatar_url: user.avatar_url,
      flair: user.flair,
      location: user.location.presence,
      pronouns: user.pronouns.presence,
      bio: user.bio.presence,
      joined_at: user.created_at.iso8601,
      reputation: user.reputation,
      top_tracks:,
      num_published_solutions: user.num_published_solutions,
      num_published_testimonials: user.num_published_testimonials,
      num_badges: user.revealed_badges.count,
      featured_badges:,
      links:
    }
  end

  private
  def top_tracks
    reputations = User::ReputationPeriod.where(
      user:,
      period: :forever,
      about: :track,
      category: :any
    ).order(reputation: :desc).limit(3).pluck(:track_id, :reputation)

    tracks = Track.where(id: reputations.map(&:first)).index_by(&:id)
    reputations.filter_map do |track_id, reputation|
      track = tracks[track_id]
      next unless track

      { slug: track.slug, title: track.title, reputation: }
    end
  end

  def featured_badges
    user.featured_badges.map { |badge| { name: badge.name, rarity: badge.rarity } }
  end

  def links
    {
      github: profile.github.presence && "https://github.com/#{profile.github}",
      linkedin: profile.linkedin.presence,
      twitter: profile.twitter.presence && "https://twitter.com/#{profile.twitter}",
      website: profile.website.presence
    }.compact
  end

  memoize
  def profile = user.profile
end
