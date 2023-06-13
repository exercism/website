# Once this is in production and everything is updated
# we can get rid of the DEFAULT_FIELDS logic
class User::Data < ApplicationRecord
  include User::Roles

  scope :donors, -> { where.not(first_donated_at: nil) }

  belongs_to :user

  enum insiders_status: {
    unset: 0,
    ineligible: 1,
    eligible: 2,
    eligible_lifetime: 3,
    active: 4,
    active_lifetime: 5
  }, _prefix: true

  enum email_status: {
    unverified: 0,
    verified: 1,
    invalid: 2
  }, _prefix: true

  def insiders_status = super.to_sym
  def insider? = insiders_status_active? || insiders_status_active_lifetime?
  def lifetime_insider? = insiders_status_active_lifetime?
  def donated? = first_donated_at.present?
  def onboarded? = accepted_privacy_policy_at.present? && accepted_terms_at.present?
  def email_status = super.to_sym

  def premium?
    (premium_until.present? && premium_until > Time.current)
  end

  def usages = super || (self.usages = {})

  def chatgpt_usage
    us = usages['chatgpt'] || {}
    {
      '3.5' => us['3.5'] || 0,
      '4.0' => us['4.0'] || 0
    }
  end

  # Cache methods
  %w[
    has_unrevealed_testimonials?
    has_unrevealed_badges?
    has_unseen_reputation_tokens?
  ].each do |meth|
    define_method meth do
      self.cache.key?(meth) || User::ResetCache.(user, meth)
      self.reload.cache[meth]
    end
  end
  def cache = super || (self.cache = {})

  FIELDS = %w[
    bio roles usages insiders_status cache

    github_username
    stripe_customer_id paypal_payer_id
    discord_uid

    accepted_privacy_policy_at accepted_terms_at
    became_mentor_at joined_research_at first_donated_at
    last_visited_on

    num_solutions_mentored mentor_satisfaction_percentage
    total_donated_in_cents

    active_donation_subscription show_on_supporters_page
    email_status
  ].freeze
end
