class CohortMembership < ApplicationRecord
  belongs_to :user
  belongs_to :cohort

  enum status: {
    on_waiting_list: 0,
    enrolled: 1
  }

  def member_number
    CohortMembership.where('id < ?', id).count + 1
  end

  def status = super.to_sym
end
