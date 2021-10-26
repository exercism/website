require 'test_helper'

class ConceptExerciseTest < ActiveSupport::TestCase
  test "taught_concepts works correctly" do
    exercise = create :concept_exercise
    concept = create :concept
    create :concept

    exercise.taught_concepts << concept

    assert_equal [concept], exercise.reload.taught_concepts
  end

  test "that_teach returns correct exercise" do
    ruby = create :track, slug: "ruby"
    js = create :track, slug: "js"

    ruby_bools = create :concept, track: ruby, slug: "bools"
    ruby_strings = create :concept, track: ruby, slug: "strings"
    js_bools = create :concept, track: js, slug: "bools"

    ce = create(:concept_exercise, track: ruby).tap { |e| e.taught_concepts << ruby_bools }
    create(:concept_exercise, track: ruby).tap { |e| e.taught_concepts << ruby_strings }
    create(:concept_exercise, track: js).tap { |e| e.taught_concepts << js_bools }

    assert_equal [ce], ConceptExercise.that_teach(ruby_bools)
  end

  test "instructions are correct" do
    exercise = create :concept_exercise
    assert exercise.instructions.starts_with?("In this exercise you'll be processing log-lines")
  end
end
