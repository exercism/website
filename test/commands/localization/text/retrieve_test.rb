require 'test_helper'

class Localization::Text::RetrieveTest < ActiveSupport::TestCase
  test "returns the test without a lookup if locale is english" do
    # Test GenerateKey never gets called
    Localization::Text::GenerateKey.expects(:call).never

    text = "Test instructions"
    result = Localization::Text::Retrieve.(text, :en)
    assert_equal text, result
  end

  test "works if locale is a string" do
    # Test GenerateKey never gets called
    Localization::Text::GenerateKey.expects(:call).never

    text = "Test instructions"
    result = Localization::Text::Retrieve.(text, "en")
    assert_equal text, result
  end

  test "returns a translation if it exists" do
    text = "Test instructions"
    key = Localization::Text::GenerateKey.(text)

    create :localization_original, key: key
    translation = create :localization_translation, key: key, locale: "nl", value: "Testinstructies"
    create :localization_translation, key: key, locale: "fr", value: "meh"

    result = Localization::Text::Retrieve.(text, "nl")
    assert_equal translation.value, result
  end

  test "returns nil if there's no translation" do
    text = "Test instructions"
    key = Localization::Text::GenerateKey.(text)

    # Another locale
    create :localization_original, key: key
    create :localization_translation, key: key, locale: "fr", value: "meh"

    # No translation exists
    result = Localization::Text::Retrieve.(text, "nl")
    assert_nil result

    # Ensure the key was generated correctly
    assert_equal key, Localization::Text::GenerateKey.(text)
  end
end
