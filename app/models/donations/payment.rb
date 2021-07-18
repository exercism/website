class Donations::Payment < ApplicationRecord
  belongs_to :user
  belongs_to :subscription, optional: true

  scope :subscription, -> { where.not(subscription_id: nil) }

  def amount_in_dollars
    amount_in_cents / 100.0
  end
end
