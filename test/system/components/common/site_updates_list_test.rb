require "application_system_test_case"

module Components
  module Common
    class SiteUpdateTest < ApplicationSystemTestCase
      test "user views new exercise update" do
        author = create :user, handle: "Author"
        exercise = create :concept_exercise, title: "Bob", authors: [author]
        create :new_exercise_site_update, exercise:, published_at: 1.day.ago

        visit test_components_common_site_updates_list_path

        assert_text "Author published a new Exercise"
        assert_link "Bob", href: Exercism::Routes.track_exercise_url(exercise.track, exercise)
        assert_text "Yesterday"
        assert_css "img[src='#{exercise.icon_url}']"
        assert_css "img[src='#{author.avatar_url}']"
      end

      test "user views new concept update" do
        strings = create :concept, name: "Strings"
        create :new_concept_site_update,
          published_at: 1.day.ago,
          params: { concept: strings },
          track: strings.track

        visit test_components_common_site_updates_list_path

        assert_text "We published a new Concept"
        assert_link "Strings", href: Exercism::Routes.track_concept_url(strings.track, strings)
        assert_text "Yesterday"
        assert_css ".c-concept-icon", text: "St"
      end

      test "user views expanded site update" do
        author = create :user, handle: "Author"
        update = create :new_exercise_site_update,
          author:,
          title: "New exercise",
          description_markdown: "New description"

        visit test_components_common_site_updates_list_path

        within(".expanded") do
          assert_text "New exercise"
          assert_text "by Author"
          assert_text "New description"
          assert_css "img[src='#{update.exercise.icon_url}']"
          assert_css "img[src='#{update.exercise.track.icon_url}']"
        end
      end

      test "user views pull request widget" do
        author = create :user
        pull_request = create :github_pull_request,
          title: "First PR",
          number: "3",
          merged_by_username: "iHiD",
          updated_at: 2.days.ago,
          repo: "exercism/ruby"
        create(:new_exercise_site_update,
          author:,
          title: "New exercise",
          description_markdown: "New description",
          pull_request:)

        visit test_components_common_site_updates_list_path

        assert_link "First PR", href: "https://github.com/exercism/ruby/pull/3"
        assert_link "#3 merged 2 days ago by iHiD"
      end

      test "user views update with track icon" do
        author = create :user, handle: "Author"
        track = create :track
        exercise = create(:concept_exercise, title: "Bob", authors: [author], track:)
        create :new_exercise_site_update, exercise:, published_at: 1.hour.ago

        visit test_components_common_site_updates_list_path(icon: "track")
        assert_css "img[src='#{track.icon_url}']"
      end

      test "user views exercise widget" do
        author = create :user, handle: "Author"
        exercise = create :concept_exercise, title: "Bob"
        create :new_exercise_site_update,
          author:,
          exercise:,
          title: "New exercise",
          description_markdown: "New description"

        visit test_components_common_site_updates_list_path

        assert_link "Bob", href: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      end

      test "user views concept widget" do
        author = create :user
        strings = create :concept, name: "Strings"
        create :new_concept_site_update,
          published_at: 1.day.ago,
          params: { concept: strings },
          track: strings.track,
          author:,
          title: "New concept",
          description_markdown: "New description"

        visit test_components_common_site_updates_list_path

        assert_link "Strings", href: Exercism::Routes.track_concept_path(strings.track, strings)
      end
    end
  end
end
