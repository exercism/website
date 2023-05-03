class SerializeAuthorOrContributor
  include Mandate

  initialize_with :user

  def call
    {
      name: user.name,
      handle: user.handle,
      flair: user.flair,
      avatar_url: user.avatar_url,
      reputation: user.formatted_reputation,
      links: {
        profile: user.profile? ? Exercism::Routes.profile_url(user) : nil
      }
    }
  end
end
