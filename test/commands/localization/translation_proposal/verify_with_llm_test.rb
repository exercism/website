require 'test_helper'

class Localization::TranslationProposal::VerifyWithLLMTest < ActiveSupport::TestCase
  test "calls gemini with correct params" do
    usage_details = <<~USAGE_DETAILS
      This text is used in the user interface of a web application. It should be clear, concise, and user-friendly. The tone should be professional yet approachable, ensuring that users feel comfortable and informed while navigating the application.
    USAGE_DETAILS

    original = create :localization_original, usage_details: usage_details
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation

    expected_endpoint = "localization_verify_translation_proposal?proposal_uuid=#{proposal.uuid}"

    LLM::ExecGeminiFlash.expects(:call).with do |prompt, endpoint|
      assert_equal expected_endpoint, endpoint

      assert_includes prompt, translation.locale
      assert_includes prompt, original.value
      assert_includes prompt, proposal.value
      assert_includes prompt, usage_details
    end

    Localization::TranslationProposal::VerifyWithLLM.(proposal)
  end
end
