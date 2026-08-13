# Everything the image generator needs to draw a profile's share image, in one
# request. The counterpart to SerializeSolutionImage: the shape mirrors what
# app/views/images/profile.html.haml draws, so the generator needs no browser.
class SerializeProfileImage
  include Mandate

  initialize_with :user

  def call
    {
      header: {
        handle: user.handle,
        name: user.name,
        avatar_url: user.avatar_url,
        flair: user.flair,
        reputation: user.reputation,
        badges:,
        tags:
      },
      categories:
    }
  end

  private
  # Icon, not slug: the generator looks up its vendored artwork by icon name, and
  # deriving a slug from the class name is lossy (Completed12In23Badge).
  def badges
    user.featured_badges.map { |badge| { icon: badge.icon, rarity: badge.rarity } }
  end

  # profile.html.haml draws the founder pill *instead of* the other tags.
  def tags
    return ["Exercism Founder"] if user.founder?

    tags = []
    tags << "Exercism Staff" if user.staff?
    tags << "Maintainer" if user.maintainer?
    tags << "Insider" if user.insider?
    tags.take(2)
  end

  # The first track is the "all tracks" set, already in the order the chart's
  # axes assume.
  def categories
    summary = AssembleContributionsSummary.(user, for_self: false)

    summary[:tracks].first[:categories].map do |category|
      {
        id: category[:id],
        metric: category[:metric_full],
        reputation: category[:reputation]
      }
    end
  end
end
