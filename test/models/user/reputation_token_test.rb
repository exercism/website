require 'test_helper'

class User::ReputationTokenTest < ActiveSupport::TestCase
  test "creates with category and reason" do
    category = :mentoring
    reason = :mentored
    context = create :concept_solution

    acq = create :user_reputation_token, category: category, reason: reason, context: context
    assert_equal category, acq.category
    assert_equal reason, acq.reason
    assert_equal context, acq.context
  end

  test "raises when no value specified for reason" do
    reason = :some_other_reason
    context = create :concept_solution

    assert_raises ReputationTokenReasonInvalid do
      create :user_reputation_token, reason: reason, context: context, value: nil
    end
  end

  test "raises when invalid category specified" do
    category = :some_other_category
    reason = :committed_code
    context = create :concept_solution

    assert_raises ReputationTokenCategoryInvalid do
      create :user_reputation_token, category: category, reason: reason, context: context
    end
  end
end
