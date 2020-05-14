class User::ReputationAcquisition < ApplicationRecord
  belongs_to :user
  belongs_to :reason_object, polymorphic: true, optional: true

  def reason
    super.to_sym
  end
end
