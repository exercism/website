require 'test_helper'

class Localization::GlossaryEntryProposal::UpdateValueTest < ActiveSupport::TestCase
  test "proposal value gets updated" do
    user = create :user
    glossary_entry = create :localization_glossary_entry
    initial_translation = "Initial definition"
    updated_term = "Terrrrrm"
    updated_translation = "Updated definition"
    llm_instructions = "LLM instructions"

    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: user,
      translation: initial_translation

    Localization::GlossaryEntryProposal::UpdateValue.(proposal, user, updated_term, updated_translation, llm_instructions)

    assert_equal updated_term, proposal.reload.term
    assert_equal updated_translation, proposal.reload.translation
    assert_equal llm_instructions, proposal.llm_instructions
  end
end
