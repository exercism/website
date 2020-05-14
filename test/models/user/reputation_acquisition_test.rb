require 'test_helper'

class User::ReputationAcquisitionTest < ActiveSupport::TestCase
  test "creates with reason" do
    reason = :mentoring
    reason_object = create :concept_solution

    acq = create :user_reputation_acquisition, reason: reason, reason_object: reason_object
    assert_equal reason, acq.reason
    assert_equal reason_object, acq.reason_object
  end
end
