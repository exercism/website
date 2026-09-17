require "test_helper"

class SiteUpdates::ProcessNewExerciseUpdateTest < ActiveSupport::TestCase
  %i[active beta].each do |status|
    test "creates if #{status}" do
      exercise = create(:concept_exercise, status:)

      SiteUpdates::ProcessNewExerciseUpdate.(exercise)

      assert SiteUpdate.where(exercise:).exists?
    end

    test "updates if #{status} and exists" do
      exercise = create(:concept_exercise, status:)
      update = create(:new_exercise_site_update, exercise:)
      update.update_column(:rendering_data_cache, { "foo" => "bar" })
      assert_equal({ "foo" => "bar" }, update.rendering_data_cache) # Sanity

      SiteUpdates::ProcessNewExerciseUpdate.(exercise)

      # The stale cache is dropped, and rebuilt the next time it is rendered
      assert_empty update.reload.rendering_data_cache
      assert_equal JSON.parse(update.cacheable_rendering_data.to_json), update.rendering_data.to_h
    end
  end

  %i[wip deprecated].each do |status|
    test "does not create if #{status}" do
      exercise = create(:concept_exercise, status:)

      SiteUpdates::ProcessNewExerciseUpdate.(exercise)

      refute SiteUpdate.exists?
    end

    test "deletes if #{status} and was present" do
      exercise = create(:concept_exercise, status:)

      create(:new_exercise_site_update, exercise:)

      SiteUpdates::ProcessNewExerciseUpdate.(exercise)

      refute SiteUpdate.exists?
    end
  end
end
