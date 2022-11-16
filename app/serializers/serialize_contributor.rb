class SerializeContributor
  include Mandate

  initialize_with :user, rank: Mandate::NO_DEFAULT, contextual_data: Mandate::NO_DEFAULT

  def call
    {
      rank:,
      activity:,
      handle: user.handle,
      reputation: User::FormatReputation.(reputation),
      avatar_url: user.avatar_url,
      links: {
        profile: user.profile ? Exercism::Routes.profile_url(user) : nil
      }
    }
  end

  private
  def activity = contextual_data[:activity]
  def reputation = contextual_data[:reputation]
end
