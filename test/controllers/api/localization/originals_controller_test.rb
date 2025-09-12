require_relative '../base_test_case'

class API::Localization::OriginalsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_localization_originals_path, method: :get
  guard_incorrect_token! :api_localization_original_path, args: 1, method: :get

  ###
  # Index
  ###
  test "index returns localization orignals for the user's locales" do
    setup_user
    original = create :localization_original
    create :localization_translation, key: original.key, locale: "hu"
    create :localization_translation, key: original.key, locale: "nl"
    create :localization_translation, key: original.key, locale: "pt"

    get api_localization_originals_path, headers: @headers, as: :json

    assert_response :ok
    expected = AssembleLocalizationOriginals.(@current_user, {}).to_json
    assert_equal expected, response.body
  end

  ###
  # Show
  ###
  test "show returns a localization original with proposals" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    create(:localization_translation_proposal, translation:)

    get api_localization_original_path(original.uuid), headers: @headers, as: :json

    assert_response :ok
    expected = {
      original: SerializeLocalizationOriginal.(original, @current_user)
    }
    assert_json_response(expected)
  end
end
