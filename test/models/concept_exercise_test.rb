require 'test_helper'

class ConceptExerciseTest < ActiveSupport::TestCase
  test "taught_concepts works correctly" do
    exercise = create :concept_exercise
    concept = create :track_concept
    create :track_concept

    exercise.taught_concepts << concept

    assert_equal [concept], exercise.reload.taught_concepts
  end

  test "for! returns correct concept" do
    ruby = create :track, slug: "ruby"
    js = create :track

    ruby_bools = create :track_concept, track: ruby, slug: "bools"
    ruby_strings = create :track_concept, track: ruby, slug: "strings"
    js_bools = create :track_concept, track: js, slug: "bools"

    ce = create(:concept_exercise, track: ruby).tap { |e| e.taught_concepts << ruby_bools }
    create(:concept_exercise, track: ruby).tap { |e| e.taught_concepts << ruby_strings }
    create(:concept_exercise, track: js).tap { |e| e.taught_concepts << js_bools }

    assert_equal ce, ConceptExercise.that_teaches!(ruby_bools)
  end

  test "that_teaches! raises when no exercise teaches it" do
    concept = create :track_concept
    assert_raises ActiveRecord::RecordNotFound do
      ConceptExercise.that_teaches!(concept)
    end
  end
end
