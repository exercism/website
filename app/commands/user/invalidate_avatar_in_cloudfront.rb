class User::InvalidateAvatarInCloudfront
  include Mandate

  initialize_with :user

  def call
    return if Rails.env.development?

    Exercism.cloudfront_client.create_invalidation(
      distribution_id:,
      invalidation_batch: {
        paths: {
          quantity: 1,
          items: ["avatars/#{user.id}"]
        },
        caller_reference:
      }
    )
  end

  private
  def distribution_id
    Exercism.config.website_assets_cloudfront_distribution_id
  end

  def caller_reference
    "avatar-invalidation-for-user-#{user.id}-#{Time.current.to_i}"
  end
end
