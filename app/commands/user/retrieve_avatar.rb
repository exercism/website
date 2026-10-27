require 'open-uri'

# Returns the bytes and content type of a user's avatar, for AvatarsController.
# Only the image formats in User::AVATAR_CONTENT_TYPES are returned. Anything
# else falls back to the placeholder.
class User::RetrieveAvatar
  include Mandate

  initialize_with :user

  def self.placeholder_url = "#{Exercism.config.website_icons_host}/placeholders/user-avatar.svg"

  def call
    return attached_avatar if attached_avatar_allowed?
    return external_avatar if external_avatar_url.present?

    placeholder
  end

  private
  def attached_avatar_allowed?
    user.avatar.attached? && allowed_content_type?(user.avatar.content_type)
  end

  def attached_avatar = [user.avatar.download, user.avatar.content_type]

  def external_avatar
    data, content_type = fetch(external_avatar_url)
    return placeholder unless allowed_content_type?(content_type)

    [data, content_type]
  end

  # The placeholder is our own SVG, so we allow it by URL.
  def placeholder = fetch(self.class.placeholder_url)

  def fetch(url)
    file = URI.parse(url).open
    [file.read, file.content_type]
  end

  def allowed_content_type?(content_type) = User::AVATAR_CONTENT_TYPES.include?(content_type)

  # User#avatar_url is overridden to point at our own avatars host, so the
  # external URL has to come off the attributes directly.
  def external_avatar_url = user.attributes['avatar_url']
end
