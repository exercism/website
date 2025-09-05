require_relative '../base_test_case'

class API::Localization::GlossaryEntriesProposalsControllerTest < API::BaseTestCase
  guard_incorrect_token! :approve_api_localization_glossary_entry_proposal_path, args: 2, method: :patch

  test "create proposes a new glossary entry" do
    setup_user
    glossary_entry = create :localization_glossary_entry
    value = "New proposed glossary entry"

    Localization::GlossaryEntryProposal::Create.expects(:call).with(glossary_entry, @current_user, value)

    post api_localization_glossary_entry_proposals_path(glossary_entry), params: { value: value }, headers: @headers, as: :json
    assert_response :created

    expected = { glossary_entry: SerializeLocalizationGlossaryEntry.(glossary_entry, @current_user) }
    assert_json_response(expected)
  end

  test "approve proxies to approval" do
    setup_user
    glossary_entry = create :localization_glossary_entry
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: @current_user

    Localization::GlossaryEntryProposal::Approve.expects(:call).with(proposal, @current_user)

    patch approve_api_localization_glossary_entry_proposal_path(glossary_entry, proposal), headers: @headers, as: :json

    assert_response :ok
    expected = { glossary_entry: SerializeLocalizationGlossaryEntry.(glossary_entry, @current_user) }
    assert_json_response(expected)
  end

  test "reject proxies to rejection" do
    setup_user
    glossary_entry = create :localization_glossary_entry
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: @current_user

    Localization::GlossaryEntryProposal::Reject.expects(:call).with(proposal, @current_user)

    patch reject_api_localization_glossary_entry_proposal_path(glossary_entry, proposal), headers: @headers, as: :json

    assert_response :ok
    expected = { glossary_entry: SerializeLocalizationGlossaryEntry.(glossary_entry, @current_user) }
    assert_json_response(expected)
  end

  test "edit proxies to update value if it's the same user" do
    setup_user
    glossary_entry = create :localization_glossary_entry
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry, proposer: @current_user
    new_value = "Updated proposal value"

    Localization::GlossaryEntryProposal::UpdateValue.expects(:call).with(proposal, @current_user, new_value)

    patch api_localization_glossary_entry_proposal_path(glossary_entry, proposal), params: { value: new_value }, headers: @headers,
      as: :json

    assert_response :ok
    expected = { glossary_entry: SerializeLocalizationGlossaryEntry.(glossary_entry, @current_user) }
    assert_json_response(expected)
  end

  test "rejects and creates a new proposal if the user is different" do
    setup_user
    glossary_entry = create :localization_glossary_entry
    proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: glossary_entry
    new_value = "Updated proposal value"

    Localization::GlossaryEntryProposal::Reject.expects(:call).with(proposal, @current_user)
    Localization::GlossaryEntryProposal::Create.expects(:call).with(glossary_entry, @current_user, new_value)

    patch api_localization_glossary_entry_proposal_path(glossary_entry, proposal), params: { value: new_value }, headers: @headers,
      as: :json

    assert_response :ok
    expected = { glossary_entry: SerializeLocalizationGlossaryEntry.(glossary_entry, @current_user) }
    assert_json_response(expected)
  end
end
