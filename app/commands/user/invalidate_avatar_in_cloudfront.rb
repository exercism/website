class User::InvalidateAvatarInCloudfront
  include Mandate

  initialize_with :user

  def call
    Infrastructure::InvalidateCloudfrontItems.(
      :assets,
      items
    )
  end

  private
  memoize
  def items
    # Invalidate the old versions too. We don't want to leave
    # photos of people in our caches when they delete them.
    (0..user.version).map { |version| "/avatars/#{user.id}/#{version}" }
  end
end
