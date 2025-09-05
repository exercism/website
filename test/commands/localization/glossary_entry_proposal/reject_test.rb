require 'test_helper'

class Localization::GlossaryEntryProposal::RejectTest < ActiveSupport::TestCase
  test "reject proposal with no other ones" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "wild_term", locale: "en"
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: "Something wiiiiiild"

    Localization::GlossaryEntryProposal::Reject.(proposal, user)

    assert_equal :rejected, proposal.reload.status
    assert_equal user, proposal.reviewer

    assert_equal 0, glossary_entry.proposals.pending.count
  end

  test "reject proposals with other pending ones" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "wild_term", locale: "hu"
    proposal_1 = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: "Something wiiiiiild"
    create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: "Another wild thing"

    Localization::GlossaryEntryProposal::Reject.(proposal_1, user)

    assert_equal :rejected, proposal_1.reload.status
    assert_equal user, proposal_1.reviewer

    assert_equal 1, glossary_entry.proposals.pending.count
  end
end
