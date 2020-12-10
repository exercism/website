require 'test_helper'

class User::ReputationTokenTest < ActiveSupport::TestCase
  test "creates with reason" do
    reason = :mentoring
    context = create :concept_solution

    acq = create :user_reputation_token, reason: reason, context: context
    assert_equal reason, acq.reason
    assert_equal context, acq.context
  end

  test "raises when no amount specified for reason" do
    reason = :mentoring
    reason_object = create :concept_solution

    assert_raises ReputationTokenReasonInvalid do
      create :user_reputation_token, reason: reason, reason_object: reason_object, amount: nil
    end
  end

end
