require 'test_helper'

class Localization::Translation::ApproveLLMVersionTest < ActiveSupport::TestCase
  test "everyting gets set" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"

    Localization::Translation::ApproveLLMVersion.(translation, user)

    assert_equal :proposed, translation.reload.status
    assert_equal 1, translation.proposals.count
    proposal = translation.proposals.first
    assert_equal user, proposal.proposer
    refute proposal.modified_from_llm?
    assert_equal translation.value, proposal.value
  end
end
