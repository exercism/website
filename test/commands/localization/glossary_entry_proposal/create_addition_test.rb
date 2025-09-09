require 'test_helper'

class Localization::GlossaryEntryProposal::CreateAdditionTest < ActiveSupport::TestCase
  test "proposal gets created" do
    Localization::GlossaryEntryProposal::VerifyWithLLM.stubs(:defer)

    term = "example_term"
    locale = "hu"
    translation = "New translation"
    llm_instructions = "Verify this proposal"
    user = create :user

    proposal = Localization::GlossaryEntryProposal::CreateAddition.(term, locale, user, translation, llm_instructions)

    assert proposal.persisted?
    assert_equal :addition, proposal.type
    assert_equal translation, proposal.translation
    assert_equal user, proposal.proposer
    assert_equal term, proposal.term
    assert_equal locale, proposal.locale
  end

  test "calls LLM verification" do
    user = create :user

    Localization::GlossaryEntryProposal::VerifyWithLLM.expects(:defer)

    Localization::GlossaryEntryProposal::CreateAddition.("example_term", "hu", user, "New translation", "instructions ")
  end
end
