require 'test_helper'

class Localization::GlossaryEntryProposal::VerifyWithLLMTest < ActiveSupport::TestCase
  test "works for addition" do
    llm_instructions = "Use very very formal language"
    locale = "en"
    term = "Example Term"
    translation = "Ejemplo Término"

    proposal = create :localization_glossary_entry_proposal, :addition, translation: translation, term: term, locale: locale,
      llm_instructions: llm_instructions

    expected_endpoint = "localization_verify_glossary_entry_proposal?proposal_uuid=#{proposal.uuid}"

    LLM::ExecGeminiFlash.expects(:call).with do |prompt, endpoint|
      assert_equal expected_endpoint, endpoint

      assert_includes prompt, locale
      assert_includes prompt, term
      assert_includes prompt, translation
      assert_includes prompt, llm_instructions
    end

    Localization::GlossaryEntryProposal::VerifyWithLLM.(proposal)
  end

  test "works for modification" do
    llm_instructions = "Use very very VERY!!! formal language"
    locale = "en"
    term = "Example Term"
    translation = "Ejemplo Término"

    glossary_entry = create :localization_glossary_entry, term: term, locale: locale
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, translation: translation,
      llm_instructions: llm_instructions

    expected_endpoint = "localization_verify_glossary_entry_proposal?proposal_uuid=#{proposal.uuid}"

    LLM::ExecGeminiFlash.expects(:call).with do |prompt, endpoint|
      assert_equal expected_endpoint, endpoint

      assert_includes prompt, locale
      assert_includes prompt, term
      assert_includes prompt, translation
      assert_includes prompt, llm_instructions
    end

    Localization::GlossaryEntryProposal::VerifyWithLLM.(proposal)
  end
end
