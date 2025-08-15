require 'test_helper'

class Localization::TranslationProposal::RejectTest < ActiveSupport::TestCase
  test "reject proposal with no other ones" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en", status: :proposed
    proposal = create :localization_translation_proposal, translation: translation, proposer: user, value: "Something wiiiiiild"

    Localization::TranslationProposal::Reject.(proposal, user)

    assert_equal :rejected, proposal.reload.status
    assert_equal user, proposal.reviewer

    assert_equal 0, translation.proposals.pending.count
    assert_equal :unchecked, translation.reload.status
  end

  test "reject proposals with other pending ones" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "hu", status: :proposed
    proposal_1 = create :localization_translation_proposal, translation: translation, proposer: user, value: "Something wiiiiiild"
    create :localization_translation_proposal, translation: translation, proposer: user, value: "Another wild thing"

    # Sanity
    assert_equal :proposed, translation.status

    Localization::TranslationProposal::Reject.(proposal_1, user)

    assert_equal :rejected, proposal_1.reload.status
    assert_equal user, proposal_1.reviewer

    assert_equal 1, translation.proposals.pending.count
    assert_equal :proposed, translation.reload.status
  end
end
