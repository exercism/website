class User::ReputationAcquisition < ApplicationRecord
  belongs_to :user
  belongs_to :reason_object, polymorphic: true, optional: true

  validates :reason, inclusion: {
    in: %i[exercise_authorship exercise_contributorship],
    message: "%<value>s is not a valid reason",
    strict: ReputationAcquisitionReasonInvalid
  }

  before_create do
    self.amount = REASON_AMOUNTS[self.reason]
  end

  after_save do
    total_amount = Arel.sql("(#{user.reputation_acquisitions.select('SUM(amount)').to_sql})")
    User.where(id: user.id).update_all(reputation: total_amount)
  end

  def reason
    super.to_sym
  end

  REASON_AMOUNTS = {
    exercise_authorship: 10,
    exercise_contributorship: 5
  }.freeze
  private_constant :REASON_AMOUNTS
end
