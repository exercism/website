class Cohort < ApplicationRecord
  belongs_to :track

  has_many :cohort_memberships, dependent: :destroy
  has_many :memberships, through: :cohort_memberships, source: :cohort

  def can_be_joined? = memberships.count < capacity
end
