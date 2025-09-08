require_relative '../base_test_case'

class API::Localization::GlossaryEntriesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_localization_glossary_entries_path, method: :get
  guard_incorrect_token! :api_localization_glossary_entry_path, args: 1, method: :get
  guard_incorrect_token! :api_localization_glossary_entries_path, method: :post

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

  ###
  # Create
  ###
  test "create creates a new glossary entry" do
    setup_user

    assert_difference "Localization::GlossaryEntry.count", 1 do
      post api_localization_glossary_entries_path,
        headers: @headers,
        params: {
          glossary_entry: {
            locale: "pt-BR",
            term: "Exercise",
            translation: "Exercício",
            llm_instructions: "Use this translation for exercise context"
          }
        },
        as: :json
    end

    assert_response :created
    assert_empty(JSON.parse(response.body))

    entry = Localization::GlossaryEntry.last
    assert_equal "pt-BR", entry.locale
    assert_equal "Exercise", entry.term
    assert_equal "Exercício", entry.translation
    assert_equal "Use this translation for exercise context", entry.llm_instructions
  end

  test "create handles duplicate entries gracefully" do
    setup_user

    existing_entry = create(:localization_glossary_entry,
      locale: "pt-BR",
      term: "Exercise",
      translation: "Exercício",
      llm_instructions: "Original instructions")

    assert_no_difference "Localization::GlossaryEntry.count" do
      post api_localization_glossary_entries_path,
        headers: @headers,
        params: {
          glossary_entry: {
            locale: "pt-BR",
            term: "Exercise",
            translation: "New translation",
            llm_instructions: "New instructions"
          }
        },
        as: :json
    end

    assert_response :created
    assert_empty(JSON.parse(response.body))

    # Verify the existing entry wasn't modified
    existing_entry.reload
    assert_equal "Exercício", existing_entry.translation
    assert_equal "Original instructions", existing_entry.llm_instructions
  end
end
