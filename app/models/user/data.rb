class User::Data < ApplicationRecord
  include User::Roles

  scope :donors, -> { where.not(first_donated_at: nil) }
  scope :public_supporter, -> { donors.where(show_on_supporters_page: true) }

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

  def usages = super || (self.usages = {})

  def chatgpt_usage
    us = usages['chatgpt'] || {}
    {
      '3.5' => us['3.5'] || 0,
      '4.0' => us['4.0'] || 0
    }
  end

  %w[
    has_unrevealed_testimonials?
    has_unrevealed_badges?
    has_unseen_reputation_tokens?
    num_students_mentored
    num_solutions_mentored
    num_testimonials
    num_published_testimonials
    num_published_solutions
    mentor_satisfaction_percentage
  ].each do |meth|
    define_method meth do
      return self.cache[meth] if self.cache.key?(meth)

      # This returns the new value
      User::ResetCache.(user, meth)
    end
  end
  def cache = super || (self.cache = {})
end
