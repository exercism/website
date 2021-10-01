require "test_helper"

class ConceptExercise::CreateTest < ActiveSupport::TestCase
  test "no-op if wip and not present" do
    exercise = create :concept_exercise, status: :wip

    SiteUpdates::ProcessNewExerciseUpdate.(exercise)

    refute SiteUpdate.exists?
  end

  test "deletes if wip and was present" do
    exercise = create :concept_exercise, status: :wip

    create :new_exercise_site_update, exercise: exercise

    SiteUpdates::ProcessNewExerciseUpdate.(exercise)

    refute SiteUpdate.exists?
  end

  test "creates if not wip" do
    exercise = create :concept_exercise

    SiteUpdates::ProcessNewExerciseUpdate.(exercise)

    assert SiteUpdate.where(exercise: exercise).exists?
  end

  test "updates if not wip and exists" do
    exercise = create :concept_exercise
    update = create :new_exercise_site_update, exercise: exercise
    update.update_column(:rendering_data_cache, { "foo" => "bar" })
    assert_equal({ "foo" => "bar" }, update.rendering_data_cache) # Sanity

    SiteUpdates::ProcessNewExerciseUpdate.(exercise)

    assert_equal JSON.parse(update.cacheable_rendering_data.to_json), update.reload.rendering_data_cache
  end
end
