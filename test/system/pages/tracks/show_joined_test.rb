require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Pages
  module Tracks
    class ShowJoinedTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "ensure user track is not recached" do
        track = create :track
        user = create :user
        create(:hello_world_exercise, track:)
        user_track = create(:user_track, user:, track:)

        # Generate summary then assert it should never get called again
        user_track.unlocked_concept_exercises
        UserTrack::GenerateSummaryData.expects(:call).never

        stub_latest_track_forum_threads(track)

        use_capybara_host do
          sign_in!(user)

          visit track_path(track)
        end
      end

      test "show joined on course-track in different states" do
        track = create :track, slug: 'ruby', title: "Ruby #{SecureRandom.hex}"
        hello_world = create(:hello_world_exercise, track:)
        ce_1 = create :concept_exercise, track:, slug: 'movie'
        ce_2 = create :concept_exercise, track:, slug: 'lasa'
        pe_1 = create :practice_exercise, track:, slug: 'food'
        create :practice_exercise, track:, slug: 'bob'
        create :practice_exercise, track:, slug: 'leap', status: :deprecated
        create :practice_exercise, track:, slug: 'iso', status: :wip
        c_1 = create(:concept, track:)
        c_2 = create(:concept, track:)
        ce_1.taught_concepts << c_1
        ce_2.taught_concepts << c_2
        pe_1.prerequisites << c_1

        user = create :user
        create(:user_track, user:, track:)

        stub_latest_track_forum_threads(track)

        use_capybara_host do
          sign_in!(user)

          visit track_path(track)
          assert_text "1 Exercise available"
          assert_text "4 Exercises locked"

          create :practice_solution, :completed, user:, exercise: hello_world
          visit track_path(track)
          assert_text "1 Exercise completed"
          assert_text "3 Exercises available"

          create :concept_solution, :completed, user:, exercise: ce_1
          visit track_path(track)
          assert_text "2 Exercises completed"
          assert_text "1 Concept learnt"
          assert_text "1 Concept mastered"
        end
      end

      test "show joined on non-course-track in different states" do
        track = create :track, slug: 'ruby', title: "Ruby #{SecureRandom.hex}"
        hello_world = create(:hello_world_exercise, track:)
        pe_1 = create :practice_exercise, track:, slug: 'bob'
        create :practice_exercise, track:, slug: 'food'
        create :practice_exercise, track:, slug: 'leap', status: :deprecated
        create :practice_exercise, track:, slug: 'iso', status: :wip

        user = create :user
        create(:user_track, user:, track:)

        stub_latest_track_forum_threads(track)

        use_capybara_host do
          sign_in!(user)

          visit track_path(track)
          assert_text "1 Exercise available"
          assert_text "2 Exercises locked"

          create :practice_solution, :completed, user:, exercise: hello_world
          visit track_path(track)
          assert_text "1 Exercise completed"
          assert_text "2 Exercises available"

          create :practice_solution, :completed, user:, exercise: pe_1
          visit track_path(track)
          assert_text "2 Exercises completed"
          assert_text "1 Exercise available"
        end
      end
    end
  end
end
