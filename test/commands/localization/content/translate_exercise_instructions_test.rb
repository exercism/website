require 'test_helper'

class Localization::Content::TranslateExerciseInstructionsTest < ActiveSupport::TestCase
  test "returns instructions without lookup if locale is english" do
    exercise = Struct.new(:id, :instructions).new(123, "These are the instructions")

    Localization::Translation.expects(:find_by).never
    Localization::Text::Translate.expects(:call).never

    result = Localization::Content::TranslateExerciseInstructions.(exercise, locale: :en)
    assert_equal exercise.instructions, result
  end

  test "returns existing translation if present" do
    instructions_text = "These are the instructions"
    exercise = Struct.new(:id, :instructions).new(456, instructions_text)

    key = Localization::Text::GenerateKey.(instructions_text)
    create :localization_original, key: key, value: instructions_text
    translation = create :localization_translation, key: key, locale: "nl", value: "Dit zijn de instructies"

    Localization::Text::Translate.expects(:call).never

    result = Localization::Content::TranslateExerciseInstructions.(exercise, locale: :nl)
    assert_equal translation.value, result
  end

  test "delegates to Text::Translate when translation missing" do
    instructions_text = "Do the thing"
    exercise = Struct.new(:id, :instructions).new(789, instructions_text)

    expected = "Translated value"
    Localization::Text::Translate.expects(:call).with(:exercise_instructions, instructions_text, exercise.id, :nl).returns(expected)

    result = Localization::Content::TranslateExerciseInstructions.(exercise, locale: :nl)
    assert_equal expected, result
  end
end
