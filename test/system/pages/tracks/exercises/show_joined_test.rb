require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Pages
  module Tracks
    module Exercises
      class ShowJoinedTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "exercise page in different states" do
          track = create :track, slug: "ruby", title: "Ruby #{SecureRandom.hex}"
          hello_world = create(:hello_world_exercise, track:)
          ce_1 = create :concept_exercise, track:, slug: 'movie'
          ce_2 = create :concept_exercise, track:, slug: 'team'
          ce_3 = create :concept_exercise, track:, slug: 'book', status: :deprecated
          pe_1 = create :practice_exercise, track:, slug: 'bob'
          pe_2 = create :practice_exercise, track:, slug: 'iso'
          c_1 = create :concept, track:, slug: 'basics'
          c_2 = create :concept, track:, slug: 'strings'
          ce_1.taught_concepts << c_1
          ce_2.taught_concepts << c_2
          ce_3.taught_concepts << c_1
          ce_2.prerequisites << c_1
          pe_1.prerequisites << c_1
          pe_2.prerequisites << c_1
          pe_2.prerequisites << c_2

          user = create :user
          create(:user_track, user:, track:)

          use_capybara_host do
            sign_in!(user)

            # Locked due to 'hello-world' exercise not being completed
            visit track_exercise_path(track, ce_1)
            assert_text "Unlock Movie"

            create(:practice_solution, :completed, exercise: hello_world, user:)

            # Unlocked due to 'hello-world' exercise being completed
            visit track_exercise_path(track, ce_1)
            assert_text "Start Movie"

            # Locked due to 'basics' Concept not being unlocked, which is taught by the 'movie' Concept Exercise)
            visit track_exercise_path(track, ce_2)
            assert_text "Unlock Team"
            assert_text "Movie"

            # Locked due to 'basics' Concept not being unlocked, which is taught by the 'movie' Concept Exercise)
            visit track_exercise_path(track, pe_1)
            assert_text "Unlock Bob"
            assert_text "Movie"

            # Locked due to 'basics' Concept not being unlocked, which is taught by the 'movie' Concept Exercise)
            # Locked due to 'strings' Concept not being unlocked, which is taught by the 'team' Concept Exercise)
            visit track_exercise_path(track, pe_2)
            assert_text "Unlock Iso"
            assert_text "Movie"
            assert_text "Team"

            create :concept_solution, :completed, user:, exercise: ce_1

            # Unlocked due to 'basics' Concept being unlocked after completing the 'movie' Concept Exercise
            visit track_exercise_path(track, ce_2)
            assert_text "Start in editor"

            # Unlocked due to 'basics' Concept being unlocked after completing the 'movie' Concept Exercise
            visit track_exercise_path(track, pe_1)
            assert_text "Start in editor"

            # Locked due to 'strings' Concept not being unlocked, which is taught by the 'team' Concept Exercise)
            visit track_exercise_path(track, pe_2)
            assert_text "Unlock Iso"
            assert_text "Team"

            create :concept_solution, :completed, user:, exercise: ce_2

            # Unlocked due to 'basics' Concept being unlocked after completing the 'movie' Concept Exercise
            # Unlocked due to 'strings' Concept being unlocked after completing the 'team' Concept Exercise
            visit track_exercise_path(track, pe_2)
            assert_text "Start in editor"
          end
        end

        test "exercise page always unlocked for admin user" do
          track = create :track, slug: "ruby", title: "Ruby #{SecureRandom.hex}"
          ce_1 = create :concept_exercise, track:, slug: 'movie'
          ce_2 = create :concept_exercise, track:, slug: 'team'
          ce_3 = create :concept_exercise, track:, slug: 'book', status: :deprecated
          pe_1 = create :practice_exercise, track:, slug: 'bob'
          pe_2 = create :practice_exercise, track:, slug: 'iso'
          c_1 = create :concept, track:, slug: 'basics'
          c_2 = create :concept, track:, slug: 'strings'
          ce_1.taught_concepts << c_1
          ce_2.taught_concepts << c_2
          ce_3.taught_concepts << c_1
          ce_2.prerequisites << c_1
          pe_1.prerequisites << c_1
          pe_2.prerequisites << c_1
          pe_2.prerequisites << c_2

          user = create :user, roles: [:admin]
          create(:user_track, user:, track:)

          use_capybara_host do
            sign_in!(user)

            # Normally locked due to 'hello-world' exercise not being completed
            visit track_exercise_path(track, ce_1)
            assert_text "Start Movie"

            # Normally locked due to 'basics' Concept not being unlocked, which is taught by the 'movie' Concept Exercise)
            visit track_exercise_path(track, ce_2)
            assert_text "Start Team"

            # Normally locked due to 'basics' Concept not being unlocked, which is taught by the 'movie' Concept Exercise)
            visit track_exercise_path(track, pe_1)
            assert_text "Start Bob"

            # Normally locked due to 'basics' Concept not being unlocked, which is taught by the 'movie' Concept Exercise)
            # Normally locked due to 'strings' Concept not being unlocked, which is taught by the 'team' Concept Exercise)
            visit track_exercise_path(track, pe_2)
            assert_text "Start Iso"

            # Normally locked due to 'strings' Concept not being unlocked, which is taught by the 'team' Concept Exercise)
            visit track_exercise_path(track, pe_2)
            assert_text "Start Iso"
          end
        end

        test "exercise page for exercise with append instructions" do
          track = create :track, slug: "ruby", title: "Ruby #{SecureRandom.hex}"
          pe = create :practice_exercise, track:, slug: 'bob', status: :active

          user = create :user
          create(:user_track, user:, track:)

          use_capybara_host do
            sign_in!(user)

            visit track_exercise_path(track, pe)
            assert_text "Instructions for bob"
            assert_text "Extra instructions for bob"
          end
        end

        test "switching to practice mode unlocks things" do
          track = create :track, slug: "ruby", title: "Ruby #{SecureRandom.hex}"
          ce = create :concept_exercise, track:, slug: 'movie'
          pe = create :practice_exercise, track:, slug: 'bob'
          concept = create :concept, track:, slug: 'basics'
          ce.taught_concepts << concept
          pe.prerequisites << concept

          user = create :user
          create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
          create(:user_track, user:, track:)
          create(:hello_world_solution, :completed, track:, user:)
          stub_latest_track_forum_threads(track)

          use_capybara_host do
            sign_in!(user.reload)
            visit track_path(track)

            click_on "Practice"
            within(".c-exercise-widget:last-child") { assert_text "Locked" }

            click_on "Track options"
            click_on "Disable Learning Mode…"
            click_on "Disable Learning Mode"

            click_on "Practice"
            within(".c-exercise-widget:last-child") { refute_text "Locked" }
          end
        end
      end
    end
  end
end
