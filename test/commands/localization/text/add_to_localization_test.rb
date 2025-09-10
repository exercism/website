require 'test_helper'

class Localization::Text::AddToLocalizationTest < ActiveSupport::TestCase
  test "returns existing original" do
    Localization::Original::Translate.stubs(:call)

    text = "Test instructions"
    key = Localization::Text::GenerateKey.(text)

    original = create :localization_original, key: key, value: text
    result = Localization::Text::AddToLocalization.(:exercise_instructions, text, nil, priority_locale: "nl")

    assert_equal original, result
  end

  test "triggers priority locale if there is one" do
    text = "Test instructions"
    key = Localization::Text::GenerateKey.(text)

    original = create :localization_original, key: key, value: text
    priority_locale = "nl"

    Localization::Original::Translate.expects(:call).with(original, priority_locale)

    Localization::Text::AddToLocalization.(:exercise_instructions, text, nil, priority_locale: priority_locale)
  end

  test "queues non-existing locales" do
    I18n.stubs(available_locales: %i[hu pt es])
    I18n.stubs(wip_locales: %i[fr nl de])

    text = "Test instructions"
    key = Localization::Text::GenerateKey.(text)

    original = create :localization_original, key: key, value: text

    # Remove one from each list
    create :localization_translation, key: key, locale: "hu", value: "Dutch translation"
    create :localization_translation, key: key, locale: "nl", value: "French translation"

    # Stub TranslateToAllLocales.defer to call the method immediately
    Localization::Original::TranslateToAllLocales.stubs(:defer).with(original) do |orig|
      Localization::Original::TranslateToAllLocales.(orig)
    end

    Localization::Original::Translate.expects(:defer).with(original, :pt)
    Localization::Original::Translate.expects(:defer).with(original, :es)
    Localization::Original::Translate.expects(:defer).with(original, :fr)
    Localization::Original::Translate.expects(:defer).with(original, :de)

    Localization::Text::AddToLocalization.(:exercise_instructions, text, nil)
  end
end
