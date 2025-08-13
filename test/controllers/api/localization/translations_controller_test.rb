require_relative '../base_test_case'

class API::Localization::TranslationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :approve_llm_version_api_localization_translation_path, args: 1, method: :patch

  test "approve_llm_version creates proposal and updates status" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"

    Localization::Translation::ApproveLLMVersion.expects(:call).with(translation, @current_user)

    patch approve_llm_version_api_localization_translation_path(translation.uuid), headers: @headers, as: :json

    assert_response :ok
  end
end
