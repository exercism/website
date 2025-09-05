require 'test_helper'

class SerializeLocalizationOriginalTest < ActiveSupport::TestCase
  test "serializes without translations" do
    user = create(:user)
    original = create(:localization_original, key: "greeting", value: "Hello")

    expected = {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
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
      translations: [
        SerializeLocalizationTranslation.(translation_fr),
        SerializeLocalizationTranslation.(translation_pt)
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

    create(:localization_translation_proposal, translation: translation_fr, value: "Salut")
    create(:localization_translation_proposal, translation: translation_pt, value: "Oi")

    # Rejected
    create :localization_translation_proposal, translation: translation_fr, value: "Hello", status: :rejected

    expected = {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      translations: [
        SerializeLocalizationTranslation.(translation_fr),
        SerializeLocalizationTranslation.(translation_pt)
      ]
    }

    assert_equal expected, SerializeLocalizationOriginal.(original, user)
  end
end
