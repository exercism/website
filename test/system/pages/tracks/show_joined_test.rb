require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Pages
  module Tracks
    class ShowJoinedTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "show joined on course-track in different states" do
        track = create :track, slug: :ruby_1, title: "Ruby #{SecureRandom.hex}"
        hello_world = create :hello_world_exercise, track: track
        ce_1 = create :concept_exercise, track: track, slug: 'movie'
        ce_2 = create :concept_exercise, track: track, slug: 'lasa'
        pe_1 = create :practice_exercise, track: track, slug: 'food'
        create :practice_exercise, track: track, slug: 'bob'
        create :practice_exercise, track: track, slug: 'leap', status: :deprecated
        create :practice_exercise, track: track, slug: 'iso', status: :wip
        c_1 = create :concept, track: track
        c_2 = create :concept, track: track
        ce_1.taught_concepts << c_1
        ce_2.taught_concepts << c_2
        pe_1.prerequisites << c_1

        user = create :user
        create :user_track, user: user, track: track

        use_capybara_host do
          sign_in!(user)

          visit track_path(track)
          assert_text "1\nExercise available"
          assert_text "4\nExercises locked"

          create :practice_solution, :completed, user: user, exercise: hello_world
          visit track_path(track)
          assert_text "1\nExercise completed"
          assert_text "3\nExercises available"

          create :concept_solution, :completed, user: user, exercise: ce_1
          visit track_path(track)
          assert_text "2\nExercises completed"
          assert_text "1\nConcept learnt"
          assert_text "1\nConcept mastered"
        end
      end

      test "show joined on non-course-track in different states" do
        track = create :track, slug: :ruby_1, title: "Ruby #{SecureRandom.hex}"
        hello_world = create :hello_world_exercise, track: track
        pe_1 = create :practice_exercise, track: track, slug: 'bob'
        create :practice_exercise, track: track, slug: 'food'
        create :practice_exercise, track: track, slug: 'leap', status: :deprecated
        create :practice_exercise, track: track, slug: 'iso', status: :wip

        user = create :user
        create :user_track, user: user, track: track

        stub_latest_track_forum_threads(track)

        use_capybara_host do
          sign_in!(user)

          visit track_path(track)
          assert_text "1\nExercise available"
          assert_text "2\nExercises locked"

          create :practice_solution, :completed, user: user, exercise: hello_world
          visit track_path(track)
          assert_text "1\nExercise completed"
          assert_text "2\nExercises available"

          create :practice_solution, :completed, user: user, exercise: pe_1
          visit track_path(track)
          assert_text "2\nExercises completed"
          assert_text "1\nExercise available"
        end
      end
    end
  end
end
