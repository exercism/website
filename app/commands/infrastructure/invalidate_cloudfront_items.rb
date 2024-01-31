class Infrastructure::InvalidateCloudfrontItems
  include Mandate

  initialize_with :distribution_slug, :items

  def call
    return unless Rails.env.production?
    raise "Invalid distribution" unless %i[assets website].include?(distribution_slug)

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
  def distribution_id
    case distribution_slug
    when :assets
      Exercism.config.assets_cloudfront_distribution_id
    when :website
      Exercism.config.website_cloudfront_distribution_id
    end
  end

  def caller_reference
    "website-invalidation-#{Time.current.to_i}-#{SecureRandom.uuid}"
  end
end
