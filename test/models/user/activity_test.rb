require "test_helper"

class User::ActivityTest < ActiveSupport::TestCase
  test "creates correctly" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)
      solution = create(:concept_solution, exercise:)
      track = exercise.track

      activity = User::Activities::StartedExerciseActivity.create!(
        user:,
        track:,
        solution:
      )

      assert_equal user, activity.user
      assert_equal track, activity.track
      assert_equal Time.current, activity.occurred_at
    end
  end

  test "rendering data reads cache" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)
      solution = create(:concept_solution, exercise:)

      User::Activities::StartedExerciseActivity.create!(
        user:,
        track: exercise.track,
        solution:
      )

      # Reload it to check nothing is memoized
      activity = User::Activity.last
      activity.expects(:cacheable_rendering_data).never

      cache_data = {
        'url' => "/tracks/ruby/exercises/strings",
        'text' => "You started <strong>Strings</strong>",
        'icon_name' => "editor"
      }
      assert_equal cache_data, activity.rendering_data_cache
      assert_equal "/tracks/ruby/exercises/strings", activity.rendering_data[:url]
      assert_equal "You started <strong>Strings</strong>", activity.rendering_data[:text]
      assert_equal Time.current, activity.rendering_data[:occurred_at]
    end
  end

  test "rendering data rebuilds if cache is empty" do
    freeze_time do
      user = create :user
      exercise = create(:concept_exercise)
      solution = create(:concept_solution, exercise:)

      activity = User::Activities::StartedExerciseActivity.create!(
        user:,
        track: exercise.track,
        solution:
      )
      activity.update!(rendering_data_cache: {})

      # Reload it to check the cache has been rebuilt
      activity = User::Activity.last
      assert_equal "/tracks/ruby/exercises/strings", activity.rendering_data[:url]
      assert_equal "You started <strong>Strings</strong>", activity.rendering_data[:text]
      assert_equal Time.current, activity.rendering_data[:occurred_at]
      cache_data = {
        'url' => "/tracks/ruby/exercises/strings",
        'text' => "You started <strong>Strings</strong>",
        'icon_name' => "editor"
      }
      assert_equal cache_data, activity.rendering_data_cache
    end
  end
end
