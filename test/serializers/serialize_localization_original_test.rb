require 'test_helper'

class SerializeLocalizationOriginalTest < ActiveSupport::TestCase
  test "serializes without translations" do
    user = create(:user)
    original = create(:localization_original, key: "greeting", value: "Hello")

    expected = {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      sample_interpolations: [],
      translations: []
    }

    assert_equal expected, SerializeLocalizationOriginal.(original, user)
  end

  test "translations" do
    user = create(:user)
    user.stubs(translator_locales: %w[pt fr])
    original = create(:localization_original, key: "greeting", value: "Hello")
    create(:localization_translation, key: original.key, locale: "en", value: "Hello")
    translation_fr = create(:localization_translation, key: original.key, locale: "fr", value: "Bonjour")
    create(:localization_translation, key: original.key, locale: "de", value: "Hallo")
    translation_pt = create(:localization_translation, key: original.key, locale: "pt", value: "Olá")

    expected = {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      sample_interpolations: [],
      translations: [
        { uuid: translation_fr.uuid, locale: "fr", value: translation_fr.value, status: translation_fr.status, proposals: [] },
        { uuid: translation_pt.uuid, locale: "pt", value: translation_pt.value, status: translation_pt.status, proposals: [] }
      ]
    }

    assert_equal expected, SerializeLocalizationOriginal.(original, user)
  end

  test "proposals" do
    user = create(:user)
    user.stubs(translator_locales: %w[pt fr])
    original = create(:localization_original, key: "greeting", value: "Hello")
    create(:localization_translation, key: original.key, locale: "en", value: "Hello")
    translation_fr = create(:localization_translation, key: original.key, locale: "fr", value: "Bonjour")
    translation_pt = create(:localization_translation, key: original.key, locale: "pt", value: "Olá")

    proposal_ = create(:localization_translation_proposal, translation: translation_fr, value: "Salut")
    proposal_2 = create(:localization_translation_proposal, translation: translation_pt, value: "Oi")

    # Rejected
    create :localization_translation_proposal, translation: translation_fr, value: "Hello", status: :rejected

    expected = {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      sample_interpolations: [],
      translations: [
        {
          uuid: translation_fr.uuid,
          locale: "fr",
          value: translation_fr.value,
          status: translation_fr.status,
          proposals: [
            { uuid: proposal_.uuid, status: proposal_.status, value: proposal_.value, proposer: proposal_.proposer&.user_id,
              reviewer: proposal_.reviewer&.user_id }
          ]
        },
        {
          uuid: translation_pt.uuid,
          locale: "pt",
          value: translation_pt.value,
          status: translation_pt.status,
          proposals: [
            { uuid: proposal_2.uuid, status: proposal_2.status, value: proposal_2.value, proposer: proposal_2.proposer&.user_id,
              reviewer: proposal_2.reviewer&.user_id }
          ]
        }
      ]
    }

    assert_equal expected, SerializeLocalizationOriginal.(original, user)
  end
end
