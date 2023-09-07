class User::InvalidateAvatarInCloudfront
  include Mandate

  initialize_with :user

  def call
    return if Rails.env.development?

    Exercism.cloudfront_client.create_invalidation(
      distribution_id:,
      invalidation_batch: {
        paths: {
          quantity: items.size,
          items:
        },
        caller_reference:
      }
    )
  end

  private
  memoize
  def items
    # Invalidate the old versions too. We don't want to leave
    # photos of people in our caches when they delete them.
    (0..user.version).map { |version| "/avatars/#{user.id}/#{version}" }
  end

  def distribution_id
    Exercism.config.website_assets_cloudfront_distribution_id
  end

  def caller_reference
    "avatar-invalidation-for-user-#{user.id}-#{Time.current.to_i}"
  end
end
