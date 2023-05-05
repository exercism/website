# Once this is in production and everything is updated
# we can get rid of the DEFAULT_FIELDS logic
class User::Data < ApplicationRecord
  include User::Roles

  belongs_to :user

  enum insiders_status: {
    unset: 0,
    ineligible: 1,
    eligible: 2,
    eligible_lifetime: 3,
    active: 4,
    active_lifetime: 5
  }, _prefix: true

  def insiders_status = super.to_sym
  def donated? = first_donated_at.present?
  def onboarded? = accepted_privacy_policy_at.present? && accepted_terms_at.present?

  # Cache methods
  %w[
    has_unrevealed_testimonials?
    has_unrevealed_badges?
    has_unseen_reputation_tokens?
  ].each do |meth|
    define_method meth do
      self.cache.presence || User::ResetCache.defer(user)
      self.cache[meth]
    end
  end

  FIELDS = %w[
    bio roles insiders_status

    stripe_customer_id discord_uid

    accepted_privacy_policy_at accepted_terms_at
    became_mentor_at joined_research_at first_donated_at
    last_visited_on

    num_solutions_mentored mentor_satisfaction_percentage
    total_donated_in_cents

    active_donation_subscription show_on_supporters_page
  ].freeze
end
