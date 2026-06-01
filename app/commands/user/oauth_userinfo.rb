class User::OauthUserinfo
  include Mandate

  initialize_with :user

  def call
    {
      id: user.id,
      handle: user.handle,
      name: user.name,
      email: user.email,
      avatar_url: absolute_avatar_url,
      membership_status:
    }
  end

  private
  def absolute_avatar_url
    url = user.avatar_url
    return url if url.start_with?('http://', 'https://')

    host = Rails.application.routes.default_url_options[:host].to_s
    host = "https://#{host}" unless host.start_with?('http://', 'https://')
    "#{host}#{url}"
  end

  def membership_status
    return :lifetime_insider if user.data.insiders_status_active_lifetime?
    return :insider if user.data.insiders_status_active?

    :normal
  end
end
