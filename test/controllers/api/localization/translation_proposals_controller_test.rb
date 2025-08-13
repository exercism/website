require_relative '../base_test_case'

class API::Localization::TranslationsProposalsControllerTest < API::BaseTestCase
  guard_incorrect_token! :approve_api_localization_translation_proposal_path, args: 2, method: :patch

  test "create proposes a new translation" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    value = "New proposed translation"

    Localization::TranslationProposal::Create.expects(:call).with(translation, @current_user, value)

    post api_localization_translation_proposals_path(translation), params: { value: value }, headers: @headers, as: :json
    assert_response :created

    expected = { translation: SerializeLocalizationTranslation.(translation) }
    assert_json_response(expected)
  end

  test "approve creates proxies to approval" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation, proposer: @current_user

    Localization::TranslationProposal::Approve.expects(:call).with(translation, @current_user)

    patch approve_api_localization_translation_proposal_path(translation, proposal), headers: @headers, as: :json

    assert_response :ok
    expected = { translation: SerializeLocalizationTranslation.(translation) }
    assert_json_response(expected)
  end

  test "reject creates proxies to rejection" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation, proposer: @current_user

    Localization::TranslationProposal::Reject.expects(:call).with(translation, @current_user)

    patch reject_api_localization_translation_proposal_path(translation, proposal), headers: @headers, as: :json

    assert_response :ok
    expected = { translation: SerializeLocalizationTranslation.(translation) }
    assert_json_response(expected)
  end

  test "edit proxies to update value if its the same user" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation, proposer: @current_user
    new_value = "Updated proposal value"

    Localization::TranslationProposal::UpdateValue.expects(:call).with(proposal, @current_user, new_value)

    patch api_localization_translation_proposal_path(translation, proposal), params: { value: new_value }, headers: @headers, as: :json

    assert_response :ok
    expected = { translation: SerializeLocalizationTranslation.(translation) }
    assert_json_response(expected)
  end

  test "rejects and creates a new proposal if the user is different" do
    setup_user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation
    new_value = "Updated proposal value"

    Localization::TranslationProposal::Reject.expects(:call).with(proposal, @current_user)
    Localization::TranslationProposal::Create.expects(:call).with(translation, @current_user, new_value)

    patch api_localization_translation_proposal_path(translation, proposal), params: { value: new_value }, headers: @headers,
      as: :json

    assert_response :ok
    expected = { translation: SerializeLocalizationTranslation.(translation) }
    assert_json_response(expected)
  end
end
