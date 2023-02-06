class User::LinkWithGithub
  include Mandate

  initialize_with :user, :auth

  def call
    user.update!(
      provider: auth.provider,
      uid: auth.uid
    )

    User::SetGithubUsername.(user, auth.info.nickname)
  end
end
