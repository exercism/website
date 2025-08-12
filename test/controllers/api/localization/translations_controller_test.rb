require_relative '../base_test_case'

class API::Localization::TranslationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :approve_llm_version_api_localization_translation_path, args: 1, method: :patch

  test "approve_llm_version creates proposal and updates status" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"

    patch approve_llm_version_api_localization_translation_path(translation.uuid), headers: @headers, as: :json

    assert_response :ok

    assert_equal "proposed", translation.reload.status
    assert_equal 1, translation.proposals.count
    proposal = translation.proposals.first
    assert_equal @current_user, proposal.proposer
    refute proposal.modified_from_llm?
    assert_equal translation.value, proposal.value
  end
end
