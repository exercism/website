require_relative '../base_test_case'

class API::Localization::GlossaryEntriesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_localization_glossary_entries_path, method: :get
  guard_incorrect_token! :api_localization_glossary_entry_path, args: 1, method: :get
  guard_incorrect_token! :api_localization_glossary_entries_path, method: :post
  guard_incorrect_token! :api_localization_glossary_entry_path, args: 1, method: :delete

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
  test "create creates a new glossary entry proposal" do
    setup_user

    assert_difference "Localization::GlossaryEntryProposal.count", 1 do
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

    proposal = Localization::GlossaryEntryProposal.last
    assert_equal :addition, proposal.type
    assert_equal "pt-BR", proposal.locale
    assert_equal "Exercise", proposal.term
    assert_equal "Exercício", proposal.translation
    assert_equal "Use this translation for exercise context", proposal.llm_instructions
    assert_equal @current_user, proposal.proposer
  end

  test "create allows creating proposal even for existing entries" do
    setup_user

    existing_entry = create(:localization_glossary_entry,
      locale: "pt-BR",
      term: "Exercise",
      translation: "Exercício",
      llm_instructions: "Original instructions")

    # Should still create a proposal even if entry exists
    assert_difference "Localization::GlossaryEntryProposal.count", 1 do
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

    # Verify the proposal was created
    proposal = Localization::GlossaryEntryProposal.last
    assert_equal :addition, proposal.type
    assert_equal "New translation", proposal.translation
    assert_equal "New instructions", proposal.llm_instructions
  end

  ###
  # Destroy
  ###
  test "destroy creates a deletion proposal" do
    setup_user
    glossary_entry = create :localization_glossary_entry, locale: "pt-BR", term: "Exercise"

    assert_difference "Localization::GlossaryEntryProposal.count", 1 do
      delete api_localization_glossary_entry_path(glossary_entry.uuid), headers: @headers, as: :json
    end

    assert_response :ok
    assert_empty(JSON.parse(response.body))

    proposal = Localization::GlossaryEntryProposal.last
    assert_equal :deletion, proposal.type
    assert_equal glossary_entry, proposal.glossary_entry
    assert_equal @current_user, proposal.proposer
  end

  test "destroy returns 404 for non-existent glossary entry" do
    setup_user

    assert_raises ActiveRecord::RecordNotFound do
      delete api_localization_glossary_entry_path("non-existent-uuid"), headers: @headers, as: :json
    end
  end
end
