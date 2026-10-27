class User::Profile < ApplicationRecord
  MIN_REPUTATION = 5

  extend Mandate::Memoize

  belongs_to :user

  delegate :to_param, to: :user

  normalizes :linkedin, with: lambda { |url|
    url = url.strip
    next url if url.blank?

    url = url.sub(%r{\Ahttp://}i, "https://")
    url.match?(/\A[a-z][a-z0-9+.-]*:/i) ? url : "https://#{url}"
  }

  # Only validate when the value changes, so that an existing bad value
  # doesn't stop someone saving their other profile fields.
  validate :validate_linkedin, if: :linkedin_changed?

  def self.valid_linkedin_url?(url)
    return false if url.blank?

    uri = URI.parse(url)
    return false unless uri.scheme&.downcase == "https"
    return false if uri.userinfo.present?

    host = uri.host.to_s.downcase
    host == "linkedin.com" || host.end_with?(".linkedin.com")
  rescue URI::InvalidURIError
    false
  end

  # Returns the stored LinkedIn URL if it is a valid profile URL, otherwise nil.
  def linkedin_url
    linkedin if self.class.valid_linkedin_url?(linkedin)
  end

  memoize
  def solutions_tab? = user.num_published_solutions > 3

  memoize
  def testimonials_tab? = user.num_published_testimonials.positive?

  memoize
  def contributions_tab?
    user.reputation_tokens.where(category: %i[building authoring maintaining misc]).exists?
  end

  memoize
  def badges_tab? = user.revealed_badges.exists?

  private
  def validate_linkedin
    return if linkedin.blank?
    return if self.class.valid_linkedin_url?(linkedin)

    errors.add(:linkedin, :invalid)
  end
end
