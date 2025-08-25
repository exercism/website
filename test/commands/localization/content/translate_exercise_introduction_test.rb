require 'test_helper'

class Localization::Content::TranslateExerciseIntroductionTest < ActiveSupport::TestCase
  test "returns introduction without lookup if locale is english" do
    introduction = "These are the introduction"
    exercise = create :practice_exercise
    exercise.stubs(introduction: introduction)

    Localization::Translation.expects(:find_by).never
    Localization::Text::Translate.expects(:call).never

    result = Localization::Content::TranslateExerciseIntroduction.(exercise, locale: :en)
    assert_equal exercise.introduction, result
  end

  test "returns existing translation if present" do
    introduction = "These are the introduction"
    exercise = create :practice_exercise
    exercise.stubs(introduction: introduction)

    key = Localization::Text::GenerateKey.(introduction)
    create :localization_original, key: key, value: introduction
    translation = create :localization_translation, key: key, locale: "nl", value: "Dit zijn de instructies"

    Localization::Text::Translate.expects(:call).never

    result = Localization::Content::TranslateExerciseIntroduction.(exercise, locale: :nl)
    assert_equal translation.value, result
  end

  test "delegates to Text::Translate when translation missing" do
    introduction = "These are the introduction"
    exercise = create :practice_exercise
    exercise.stubs(introduction: introduction)

    expected = "Translated value"
    Localization::Text::Translate.expects(:call).with(:exercise_introduction, introduction, exercise.id, :nl).returns(expected)

    result = Localization::Content::TranslateExerciseIntroduction.(exercise, locale: :nl)
    assert_equal expected, result
  end
end
