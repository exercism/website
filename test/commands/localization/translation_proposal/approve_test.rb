require 'test_helper'

class Localization::TranslationProposal::ApproveTest < ActiveSupport::TestCase
  test "everyting gets set" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation, proposer: user, value: "Something wiiiiiild"

    Localization::TranslationProposal::Approve.(proposal, user)

    assert_equal :checked, translation.reload.status
    assert_equal 1, translation.proposals.count
    assert_equal :approved, proposal.reload.status
    assert_equal user, proposal.reviewer
    assert_equal proposal.value, translation.value
  end
end
