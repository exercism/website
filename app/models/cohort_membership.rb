class CohortMembership < ApplicationRecord
  belongs_to :user
  belongs_to :cohort

  enum status: {
    on_waiting_list: 0,
    enrolled: 1
  }

  def status = super.to_sym
end
