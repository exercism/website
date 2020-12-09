require 'test_helper'

class User::ReputationAcquisitionTest < ActiveSupport::TestCase
  test "creates with reason" do
    reason = :exercise_authorship
    reason_object = create :exercise_authorship

    acq = create :user_reputation_acquisition, reason: reason, reason_object: reason_object
    assert_equal reason, acq.reason
    assert_equal reason_object, acq.reason_object
  end

  test "raises when no amount specified for reason" do
    reason = :mentoring
    reason_object = create :concept_solution

    assert_raises ReputationAcquisitionReasonMissingAmount do
      create :user_reputation_acquisition, reason: reason, reason_object: reason_object, amount: nil
    end
  end
end
