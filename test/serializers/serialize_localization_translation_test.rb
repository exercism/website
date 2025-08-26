require 'test_helper'
class SerializeLocalizationTranslationTest < ActiveSupport::TestCase
  test "serializes translation" do
    create(:user)
    create(:localization_original, key: "greeting", value: "Hello")
    translation = create(:localization_translation, key: "greeting", locale: "fr", value: "Bonjour")

    expected = {
      uuid: translation.uuid,
      locale: "fr",
      value: translation.value,
      status: translation.status,
      proposals: []
    }

    assert_equal expected, SerializeLocalizationTranslation.(translation)
  end

  test "serializes translation with proposals" do
    create(:user)
    create(:localization_original, key: "greeting", value: "Hello")
    translation = create(:localization_translation, key: "greeting", locale: "fr", value: "Bonjour")

    proposal_1 = create(:localization_translation_proposal, translation: translation, value: "Salut")
    proposal_2 = create(:localization_translation_proposal, translation: translation, value: "Coucou")
    create(:localization_translation_proposal, translation: translation, value: "WHAT NOW?", status: :rejected)

    expected = {
      uuid: translation.uuid,
      locale: "fr",
      value: translation.value,
      status: translation.status,
      proposals: [
        { uuid: proposal_1.uuid, status: proposal_1.status, value: proposal_1.value, proposer_id: proposal_1.proposer&.user_id,
          reviewer_id: proposal_1.reviewer&.user_id },
        { uuid: proposal_2.uuid, status: proposal_2.status, value: proposal_2.value, proposer_id: proposal_2.proposer&.user_id,
          reviewer_id: proposal_2.reviewer&.user_id }
      ]
    }

    assert_equal expected, SerializeLocalizationTranslation.(translation)
  end

  test "allows proposals to be passed in" do
    create(:user)
    create(:localization_original, key: "greeting", value: "Hello")
    translation = create(:localization_translation, key: "greeting", locale: "fr", value: "Bonjour")

    proposal_1 = create(:localization_translation_proposal, translation: translation, value: "Salut")
    create(:localization_translation_proposal, translation: translation, value: "HELLLLLOOOOO")

    expected = {
      uuid: translation.uuid,
      locale: "fr",
      value: translation.value,
      status: translation.status,
      proposals: [
        { uuid: proposal_1.uuid, status: proposal_1.status, value: proposal_1.value, proposer_id: proposal_1.proposer&.user_id,
          reviewer_id: proposal_1.reviewer&.user_id }
      ]
    }

    assert_equal expected, SerializeLocalizationTranslation.(translation, proposals: [proposal_1])
  end
end
