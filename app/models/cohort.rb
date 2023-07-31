class Cohort < ApplicationRecord
  belongs_to :track

  has_many :cohort_memberships, dependent: :destroy
  has_many :members, through: :cohort_memberships, source: :user

  def can_be_joined? = cohort_memberships.count < capacity
end
