require 'test_helper'

class Localization::Text::GenerateKeyTest < ActiveSupport::TestCase
  test "generates a key based on the text" do
    text = "This is a test string"
    key = Localization::Text::GenerateKey.(text)

    # Check if the key starts with 'arbitary.' and has a valid SHA256 hash
    assert_match(/^arbitary\.[a-f0-9]{64}$/, key)

    # Ensure the key is consistent for the same text
    assert_equal key, Localization::Text::GenerateKey.(text)
  end

  test "generates different keys for different texts" do
    text_1 = "This is the first test string"
    text_2 = "This is the second test string"

    key_1 = Localization::Text::GenerateKey.(text_1)
    key_2 = Localization::Text::GenerateKey.(text_2)

    # Ensure keys are different for different texts
    refute_equal key_1, key_2
  end

  test "raises with empty strings" do
    text = ""
    assert_raises ArgumentError do
      Localization::Text::GenerateKey.(text)
    end
  end

  test "raises with nil input" do
    text = nil
    assert_raises ArgumentError do
      Localization::Text::GenerateKey.(text)
    end
  end

  test "raises with whitespace-only strings" do
    text = "   "
    assert_raises ArgumentError do
      Localization::Text::GenerateKey.(text)
    end
  end

  test "handles special characters" do
    text = "Special characters !@#$%^&*()_+"
    key = Localization::Text::GenerateKey.(text)

    # Check if the key starts with 'arbitary.' and has a valid SHA256 hash
    assert_match(/^arbitary\.[a-f0-9]{64}$/, key)

    # Ensure the key is consistent for the same text with special characters
    assert_equal key, Localization::Text::GenerateKey.(text)
  end
end
