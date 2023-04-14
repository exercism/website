class Donations::Subscription < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(active: true) }

  enum status: { canceled: 0, overdue: 1, active: 2 }

  def amount_in_dollars
    amount_in_cents / BigDecimal(100)
  end

  def self.active_total_per_month_in_dollars
    active.sum(:amount_in_cents) / BigDecimal(100)
  end

  def status = super.to_sym
end
