require_relative '../base_test_case'

class API::Localization::GlossaryEntriesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_localization_glossary_entries_path, method: :get
  guard_incorrect_token! :api_localization_glossary_entry_path, args: 1, method: :get

  ###
  # Index
  ###
  test "index returns localization glossary entries for the user's locales" do
    setup_user
    create :localization_glossary_entry

    get api_localization_glossary_entries_path, headers: @headers, as: :json

    assert_response :ok
    expected = AssembleLocalizationGlossaryEntries.(@current_user, {}).to_json
    assert_equal expected, response.body
  end

  ###
  # Show
  ###
  test "show returns a localization glossary entry with proposals" do
    setup_user
    glossary_entry = create :localization_glossary_entry
    create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: @current_user

    get api_localization_glossary_entry_path(glossary_entry.uuid), headers: @headers, as: :json

    assert_response :ok
    expected = {
      glossary_entry: SerializeLocalizationGlossaryEntry.(glossary_entry, @current_user)
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end
end
