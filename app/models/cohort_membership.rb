class CohortMembership < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user
  belongs_to :cohort

  enum status: {
    on_waiting_list: 0,
    enrolled: 1
  }

  def status = super.to_sym

  memoize
  def position_on_waiting_list
    return unless on_waiting_list?

    CohortMembership.where(cohort:, status:).where('id <= ?', id).count
  end
end
