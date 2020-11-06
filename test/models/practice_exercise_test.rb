require 'test_helper'

class PracticeExerciseTest < ActiveSupport::TestCase
  test "that_practice returns correct exercise" do
    ruby = create :track, slug: "ruby"
    js = create :track

    ruby_bools = create :track_concept, track: ruby, slug: "bools"
    ruby_strings = create :track_concept, track: ruby, slug: "strings"
    js_bools = create :track_concept, track: js, slug: "bools"

    ce = create(:practice_exercise, track: ruby).tap { |e| e.prerequisites << ruby_bools }
    create(:practice_exercise, track: ruby).tap { |e| e.prerequisites << ruby_strings }
    create(:practice_exercise, track: js).tap { |e| e.prerequisites << js_bools }
    create(:concept_exercise, track: ruby).tap { |e| e.prerequisites << ruby_bools }

    assert_equal [ce], PracticeExercise.that_practice(ruby_bools)
  end

  test "instructions is correct" do
    exercise = create :practice_exercise
    assert exercise.instructions.starts_with?("Bob is a lackadaisical teenager")
  end
end
