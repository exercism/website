require 'test_helper'

class Localization::Text::TranslateTest < ActiveSupport::TestCase
  test "returns tranlsation if it exists" do
    text = "Test instructions"
    key = Localization::Text::GenerateKey.(text)
    locale = "nl"
    translated_text = "Testinstructies"

    create :localization_original, key: key
    create :localization_translation, key: key, locale:, value: translated_text

    result = Localization::Text::Translate.(:exercise_instructions, text, nil, locale)
    assert_equal translated_text, result
  end

  test "calles AddToLocalization and returns nil if translation does not exist" do
    text = "Test instructions"
    exercise_id = 42
    type = :exercise_instructions
    key = Localization::Text::GenerateKey.(text)

    create :localization_original, key: key

    expected = "Translated value"
    Localization::Text::AddToLocalization.expects(:call).with(type, text, exercise_id, priority_locale: "nl").returns(expected)

    result = Localization::Text::Translate.(type, text, exercise_id, "nl")
    assert_nil result
  end
end
