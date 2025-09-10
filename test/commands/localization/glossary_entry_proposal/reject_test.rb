require 'test_helper'

class Localization::GlossaryEntryProposal::RejectTest < ActiveSupport::TestCase
  test "reject proposal with no other ones" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "wild_term", locale: "en", status: :checked
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: "Something wiiiiiild"

    Localization::GlossaryEntryProposal::Reject.(proposal, user)

    assert_equal :rejected, proposal.reload.status
    assert_equal user, proposal.reviewer

    assert_equal 0, glossary_entry.proposals.pending.count
    assert_equal :unchecked, glossary_entry.reload.status
  end

  test "reject proposals with other pending ones" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "wild_term", locale: "hu", status: :checked
    proposal_1 = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: "Something wiiiiiild"
    create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: "Another wild thing"

    Localization::GlossaryEntryProposal::Reject.(proposal_1, user)

    assert_equal :rejected, proposal_1.reload.status
    assert_equal user, proposal_1.reviewer

    assert_equal 1, glossary_entry.proposals.pending.count
    assert_equal :checked, glossary_entry.reload.status # Should remain checked since there's still a pending proposal
  end

  test "reject addition proposal" do
    user = create :user
    proposal = create :localization_glossary_entry_proposal, :addition, proposer: user,
      term: "new_term", locale: "en", translation: "A new term"

    Localization::GlossaryEntryProposal::Reject.(proposal, user)

    assert_equal :rejected, proposal.reload.status
    assert_equal user, proposal.reviewer

    # No glossary entry should be created for rejected additions
    assert_equal 0, Localization::GlossaryEntry.where(term: "new_term", locale: "en").count
  end

  test "reject deletion proposal" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "term_to_delete", locale: "en", status: :checked
    proposal = create :localization_glossary_entry_proposal, :deletion, glossary_entry: glossary_entry, proposer: user

    Localization::GlossaryEntryProposal::Reject.(proposal, user)

    assert_equal :rejected, proposal.reload.status
    assert_equal user, proposal.reviewer

    # Glossary entry should still exist and status should remain unchanged
    assert glossary_entry.reload
    assert_equal :checked, glossary_entry.status
  end
end
