require 'test_helper'

class Localization::GlossaryEntryProposal::CreateDeletionTest < ActiveSupport::TestCase
  test "proposal gets created" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "example_term", locale: "hu"

    proposal = Localization::GlossaryEntryProposal::CreateDeletion.(glossary_entry, user)

    assert proposal.persisted?
    assert_equal :deletion, proposal.type
    assert_equal user, proposal.proposer
    assert_equal glossary_entry, proposal.glossary_entry
  end
end
