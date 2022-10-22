class SerializeAuthorOrContributor
  include Mandate

  initialize_with :user

  def call
    {
      name: user.name,
      handle: user.handle,
      avatar_url: user.avatar_url,
      links: {
        profile: user.profile? ? Exercism::Routes.profile_url(user) : nil
      }
    }
  end
end
