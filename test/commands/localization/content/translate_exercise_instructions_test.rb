require 'test_helper'

class Localization::Content::TranslateExerciseInstructionsTest < ActiveSupport::TestCase
  test "returns instructions without lookup if locale is english" do
    instructions = "These are the instructions"
    exercise = create :practice_exercise
    exercise.stubs(instructions: instructions)

    Localization::Translation.expects(:find_by).never
    Localization::Text::Translate.expects(:call).never

    result = Localization::Content::TranslateExerciseInstructions.(exercise, locale: :en)
    assert_equal exercise.instructions, result
  end

  test "returns existing translation if present" do
    instructions = "These are the instructions"
    exercise = create :practice_exercise
    exercise.stubs(instructions: instructions)

    key = Localization::Text::GenerateKey.(instructions)
    create :localization_original, key: key, value: instructions
    translation = create :localization_translation, key: key, locale: "nl", value: "Dit zijn de instructies"

    Localization::Text::Translate.expects(:call).never

    result = Localization::Content::TranslateExerciseInstructions.(exercise, locale: :nl)
    assert_equal translation.value, result
  end

  test "delegates to Text::Translate when translation missing" do
    instructions = "These are the instructions"
    exercise = create :practice_exercise
    exercise.stubs(instructions: instructions)

    expected = "Translated value"
    Localization::Text::Translate.expects(:call).with(:exercise_instructions, instructions, exercise, :nl).returns(expected)

    result = Localization::Content::TranslateExerciseInstructions.(exercise, locale: :nl)
    assert_equal expected, result
  end
end
