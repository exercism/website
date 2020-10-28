require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test "prerequisites works correctly" do
    exercise = create :concept_exercise

    concept = create :track_concept
    create :track_concept

    exercise.prerequisites << concept

    assert_equal [concept], exercise.reload.prerequisites
  end

  test "scope :without_prerequisites" do
    exercise_1 = create :concept_exercise
    exercise_2 = create :concept_exercise

    assert_equal [exercise_1, exercise_2], Exercise.without_prerequisites

    create :exercise_prerequisite, exercise: exercise_1
    assert_equal [exercise_2], Exercise.without_prerequisites
  end

  test "instructions is correct" do
    Git::Exercise.any_instance.unstub(:data)

    track = create :track, slug: "ruby"
    exercise = create :concept_exercise, slug: "bob", track: track
    instructions = "INSTRUCT ME"

    # TODO: Change to HEAD when downsteam supports it
    url = "#{Exercism.config.git_server_url}/exercises/ruby/bob/data?git_sha=HEAD"
    stub_request(:get, url).
      to_return(body: { exercise: { instructions: instructions } }.to_json)

    assert_equal instructions, exercise.instructions
  end
end
