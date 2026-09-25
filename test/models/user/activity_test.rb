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
      assert_equal({ "locales" => { "en" => { "version" => nil, "data" => cache_data } } }, activity.rendering_data_cache)
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
      assert_equal({ "locales" => { "en" => { "version" => nil, "data" => cache_data } } }, activity.rendering_data_cache)
    end
  end

  test "rendering data is cached per locale, with localised text and urls" do
    exercise = create(:concept_exercise)
    activity = User::Activities::StartedExerciseActivity.create!(
      user: create(:user), track: exercise.track, solution: create(:concept_solution, exercise:)
    )
    catalog = { user_activities: { started_exercise: { "1": "Elkezdted: <strong>%{exercise_title}</strong>" } } } # rubocop:disable Style/FormatStringToken

    with_published_translations(hu: { backend: catalog }) do
      publish_translated_metadata!(:hu, "track", { "exercise:strings:name" => "Szövegek" })

      I18n.with_locale(:hu) do
        activity = User::Activity.find(activity.id)
        # Even for an anonymous reader of a /hu page, the shared entry's URLs are unprefixed
        Current.set(url_locale: :hu) do
          assert_equal "Elkezdted: <strong>Szövegek</strong>", activity.rendering_data[:text]
          assert_equal "/tracks/ruby/exercises/strings", activity.rendering_data[:url]
        end

        activity = User::Activity.find(activity.id)
        activity.expects(:cacheable_rendering_data).never
        assert_equal "Elkezdted: <strong>Szövegek</strong>", activity.rendering_data[:text]
      end

      activity = User::Activity.find(activity.id)
      activity.expects(:cacheable_rendering_data).never
      assert_equal "You started <strong>Strings</strong>", activity.rendering_data[:text]
      assert_equal "/tracks/ruby/exercises/strings", activity.rendering_data[:url]
      assert_equal %w[en hu], activity.rendering_data_cache["locales"].keys
    end
  end

  test "a published translation fix re-renders the stored text" do
    exercise = create(:concept_exercise)
    activity = User::Activities::StartedExerciseActivity.create!(
      user: create(:user), track: exercise.track, solution: create(:concept_solution, exercise:)
    )

    with_published_translations(hu: { backend: { user_activities: { started_exercise: { "1": "Elkezdted" } } } }) do
      I18n.with_locale(:hu) do
        assert_equal "Elkezdted", User::Activity.find(activity.id).rendering_data[:text]

        publish_translation_catalog!(:hu, :backend, { user_activities: { started_exercise: { "1": "Elkezdted (javítva)" } } })
        assert_equal "Elkezdted (javítva)", User::Activity.find(activity.id).rendering_data[:text]
      end
    end
  end

  test "rows cached before locales existed are read as english" do
    exercise = create(:concept_exercise)
    activity = User::Activities::StartedExerciseActivity.create!(
      user: create(:user), track: exercise.track, solution: create(:concept_solution, exercise:)
    )
    activity.update_column(:rendering_data_cache, { "url" => "/legacy", "text" => "Legacy text", "icon_name" => "editor" })

    activity = User::Activity.find(activity.id)
    activity.expects(:cacheable_rendering_data).never
    assert_equal "Legacy text", activity.rendering_data[:text]

    with_published_translations(hu: { backend: { user_activities: { started_exercise: { "1": "Elkezdted" } } } }) do
      I18n.with_locale(:hu) do
        activity = User::Activity.find(activity.id)
        assert_equal "Elkezdted", activity.rendering_data[:text]
        assert_equal "Legacy text", activity.rendering_data_cache.dig("locales", "en", "data", "text")
      end
    end
  end
end
