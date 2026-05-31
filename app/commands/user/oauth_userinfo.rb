class User::OauthUserinfo
  include Mandate

  initialize_with :user

  def call
    {
      id: user.id,
      handle: user.handle,
      name: user.name,
      email: user.email,
      avatar_url: user.avatar_url,
      membership_status:
    }
  end

  private
  def membership_status
    return :lifetime_insider if user.data.insiders_status_active_lifetime?
    return :insider if user.data.insiders_status_active?

    :normal
  end
end
