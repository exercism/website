require 'test_helper'

class SerializeLocalizationOriginalsTest < ActiveSupport::TestCase
  test "serializes without translations" do
    user = create(:user)
    original = create(:localization_original, key: "greeting", value: "Hello")

    expected = [{
      uuid: original.uuid,
      key: original.key,
      title: "Unknown",
      pretty_type: "Unknown",
      value: original.value,
      translations: []
    }]

    assert_equal expected, SerializeLocalizationOriginals.([original], user)
  end

  test "includes user's translations" do
    user = create(:user)
    user.stubs(translator_locales: %w[pt fr])
    original = create(:localization_original, key: "greeting", value: "Hello")
    create(:localization_translation, key: original.key, locale: "en", value: "Hello")
    translation_fr = create(:localization_translation, key: original.key, locale: "fr", value: "Bonjour")
    create(:localization_translation, key: original.key, locale: "de", value: "Hallo")
    translation_pt = create(:localization_translation, key: original.key, locale: "pt", value: "Olá")

    expected = [{
      uuid: original.uuid,
      key: original.key,
      title: "Unknown",
      pretty_type: "Unknown",
      value: original.value,
      translations: [
        { uuid: translation_fr.uuid, locale: "fr", status: translation_fr.status },
        { uuid: translation_pt.uuid, locale: "pt", status: translation_pt.status }
      ]
    }]
    assert_equal expected, SerializeLocalizationOriginals.([original], user)
  end
end
