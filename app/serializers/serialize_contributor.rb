class SerializeContributor
  include Mandate

  def initialize(user, rank:, contextual_data:)
    @user = user
    @rank = rank
    @contextual_data = contextual_data
  end

  def call
    {
      rank: rank,
      activity: activity,
      handle: user.handle,
      reputation: User::FormatReputation.(reputation),
      avatar_url: user.avatar_url,
      links: {
        profile: user.profile ? Exercism::Routes.profile_url(user) : nil
      }
    }
  end

  private
  attr_reader :user, :rank, :contextual_data

  def activity
    contextual_data.activity
  end

  def reputation
    contextual_data.reputation
  end
end
