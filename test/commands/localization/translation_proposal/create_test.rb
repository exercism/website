require 'test_helper'

class Localization::TranslationProposal::CreateTest < ActiveSupport::TestCase
  setup do
    # Sometimes stub.
    Localization::TranslationProposal::VerifyWithLLM.define_singleton_method(:call) { |proposal| }
  end

  test "proposal gets created" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "hu"

    proposal = Localization::TranslationProposal::Create.(translation, user, "New value")

    assert proposal.persisted?
    assert_equal "New value", proposal.value
    assert_equal user, proposal.proposer
    assert_equal translation, proposal.translation
    assert_equal :proposed, translation.reload.status
    assert proposal.modified_from_llm?
  end

  test "calls LLM verification" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "hu"

    Localization::TranslationProposal::VerifyWithLLM.expects(:defer)

    Localization::TranslationProposal::Create.(translation, user, "New value")
  end
end
