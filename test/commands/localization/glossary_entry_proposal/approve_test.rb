require 'test_helper'

class Localization::GlossaryEntryProposal::ApproveTest < ActiveSupport::TestCase
  test "addition" do
    locale = "fr"
    term = "exemple"
    translation = "An example definition"
    llm_instructions = "Be very clear"
    user = create :user, reputation: 21

    proposal = create :localization_glossary_entry_proposal, :addition, locale: locale, term: term, proposer: user,
      translation: translation, llm_instructions: llm_instructions

    assert_equal 0, Localization::GlossaryEntry.count # Sanity

    Localization::GlossaryEntryProposal::Approve.(proposal, user)

    assert_equal 1, Localization::GlossaryEntry.count
    glossary_entry = Localization::GlossaryEntry.last

    assert_equal :approved, proposal.reload.status
    assert_equal user, proposal.reviewer
    assert_equal locale, glossary_entry.locale
    assert_equal term, glossary_entry.term
    assert_equal translation, glossary_entry.translation
    assert_equal llm_instructions, glossary_entry.llm_instructions
    assert_equal :checked, glossary_entry.status
  end

  test "modification" do
    translation = "Updated definition"
    llm_instructions = "Be very very clear"
    user = create :user, reputation: 21
    glossary_entry = create :localization_glossary_entry, term: "example"
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: translation, llm_instructions: llm_instructions

    Localization::GlossaryEntryProposal::Approve.(proposal, user)

    assert_equal :approved, proposal.reload.status
    assert_equal user, proposal.reviewer
    assert_equal translation, glossary_entry.reload.translation
    assert_equal llm_instructions, glossary_entry.llm_instructions
    assert_equal :checked, glossary_entry.status
  end

  test "deletion" do
    user = create :user, reputation: 21
    glossary_entry = create :localization_glossary_entry, term: "example"
    proposal = create :localization_glossary_entry_proposal, :deletion, glossary_entry: glossary_entry, proposer: user

    Localization::GlossaryEntryProposal::Approve.(proposal, user)

    assert_equal :approved, proposal.reload.status
    assert_equal user, proposal.reviewer
    assert_nil proposal.reload.glossary_entry
    assert_raises(ActiveRecord::RecordNotFound) { glossary_entry.reload }
  end
end
