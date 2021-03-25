require 'test_helper'

class PracticeExerciseTest < ActiveSupport::TestCase
  test "with_prerequisite returns correct exercise" do
    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"

    ruby_bools = create :track_concept, track: ruby, slug: "bools"
    ruby_strings = create :track_concept, track: ruby, slug: "strings"
    js_bools = create :track_concept, track: js, slug: "bools"

    ce = create(:practice_exercise, track: ruby).tap { |e| e.prerequisites << ruby_bools }
    create(:practice_exercise, track: ruby).tap { |e| e.prerequisites << ruby_strings }
    create(:practice_exercise, track: js).tap { |e| e.prerequisites << js_bools }
    create(:practice_exercise, track: ruby).tap { |e| e.practiced_concepts << ruby_bools }

    assert_equal [ce], PracticeExercise.with_prerequisite(ruby_bools)
  end

  test "that_practice returns correct exercise" do
    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"

    ruby_numbers = create :track_concept, track: ruby, slug: "numbers"
    ruby_dates = create :track_concept, track: ruby, slug: "dates"
    js_time = create :track_concept, track: js, slug: "time"

    ce = create(:practice_exercise, track: ruby).tap { |e| e.practiced_concepts << ruby_numbers }
    create(:practice_exercise, track: ruby).tap { |e| e.practiced_concepts << ruby_dates }
    create(:practice_exercise, track: js).tap { |e| e.practiced_concepts << js_time }
    create(:practice_exercise, track: ruby).tap { |e| e.prerequisites << ruby_numbers }

    assert_equal [ce], PracticeExercise.that_practice(ruby_numbers)
  end

  test "instructions is correct" do
    exercise = create :practice_exercise
    expected = "# Instructions\n\nInstructions for bob\n"
    assert_equal expected, exercise.instructions
  end
end
