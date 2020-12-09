class User::ReputationAcquisition < ApplicationRecord
  belongs_to :user
  belongs_to :reason_object, polymorphic: true, optional: true

  before_create do
    raise ReputationAcquisitionReasonMissingAmount unless self.amount || REASON_AMOUNTS[self.reason]

    self.amount = REASON_AMOUNTS[self.reason] unless self.amount
  end

  def reason
    super.to_sym
  end

  REASON_AMOUNTS = {
    'exercise_authorship': 10,
    'exercise_contributorship': 5
  }.freeze
  private_constant :REASON_AMOUNTS
end
