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
      is_insider: insider?,
      is_bootcamp_member: bootcamp_member?
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

  def insider?
    user.data.insiders_status_active? || user.data.insiders_status_active_lifetime?
  end

  def bootcamp_member?
    return true if user.bootcamp_mentor?
    return false unless user.bootcamp_data

    user.bootcamp_data.enrolled_on_part_1? || user.bootcamp_data.enrolled_on_part_2?
  end
end
