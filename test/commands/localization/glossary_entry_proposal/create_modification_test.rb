require 'test_helper'

class Localization::GlossaryEntryProposal::CreateModificationTest < ActiveSupport::TestCase
  setup do
    # Sometimes stub.
    Localization::GlossaryEntryProposal::VerifyWithLLM.define_singleton_method(:call) { |proposal| }
  end

  test "proposal gets created" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "example_term", locale: "hu"

    proposal = Localization::GlossaryEntryProposal::CreateModification.(glossary_entry, user, "Updated translation")

    assert proposal.persisted?
    assert_equal :modification, proposal.type
    assert_equal "Updated translation", proposal.translation
    assert_equal user, proposal.proposer
    assert_equal glossary_entry, proposal.glossary_entry
    assert_equal :proposed, glossary_entry.reload.status
  end

  test "calls LLM verification" do
    user = create :user
    glossary_entry = create :localization_glossary_entry, term: "example_term", locale: "hu"

    Localization::GlossaryEntryProposal::VerifyWithLLM.expects(:defer)

    Localization::GlossaryEntryProposal::CreateModification.(glossary_entry, user, "Updated translation")
  end
end
