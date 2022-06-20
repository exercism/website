class CohortMembership < ApplicationRecord
  belongs_to :user

  def member_number
    CohortMembership.where('id < ?', id).count + 1
  end
end
