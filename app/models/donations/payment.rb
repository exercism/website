class Donations::Payment < ApplicationRecord
  include Emailable

  belongs_to :user
  belongs_to :subscription, optional: true

  scope :subscription, -> { where.not(subscription_id: nil) }

  # We always want this email to be sent, so there
  # is no communication preference key
  def email_communication_preferences_key; end

  def amount_in_dollars
    amount_in_cents / BigDecimal(100)
  end

  def self.total_supporters
    select(:user_id).distinct.count
  end

  def self.total_donated_in_dollars
    sum(:amount_in_cents) / BigDecimal(100)
  end
end
