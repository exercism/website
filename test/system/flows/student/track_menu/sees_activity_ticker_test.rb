require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module TrackMenu
      class SeesActivityTickerTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "user sees submit_submission activity" do
          user = create :user
          track = create :track, title: "Ruby"
          create(:concept_exercise, track:)
          create(:user_track, user:, track:)
          submission = create :submission

          stub_latest_track_forum_threads(track)

          metric = Metric::Create.('submit_submission', Time.current, submission:, track:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            MetricsChannel.broadcast!(metric)

            assert_text "A user ran the tests for"
            assert_text submission.exercise.title
          end
        end

        test "user sees publish_solution activity" do
          user = create :user
          track = create :track, title: "Ruby"
          create(:concept_exercise, track:)
          create(:user_track, user:, track:)
          submission = create :submission
          iteration = create(:iteration, submission:)

          stub_latest_track_forum_threads(track)

          metric = Metric::Create.('publish_solution', Time.current, solution: iteration, track:, user:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            MetricsChannel.broadcast!(metric)

            assert_text user.handle
            assert_text "published a new solution for"
            assert_text submission.exercise.title
          end
        end

        test "user sees complete_solution activity" do
          user = create :user
          track = create :track, title: "Ruby"
          create(:concept_exercise, track:)
          create(:user_track, user:, track:)
          submission = create :submission
          iteration = create(:iteration, submission:)

          stub_latest_track_forum_threads(track)

          metric = Metric::Create.('complete_solution', Time.current, solution: iteration, track:, user:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            MetricsChannel.broadcast!(metric)

            assert_text "A user completed"
            assert_text submission.exercise.title
          end
        end

        test "user sees start_solution activity" do
          # TODO: Fix solution
          skip
          track = create :track, title: "Ruby"
          create(:user_track, user:, track:)
          solution = create(:practice_solution, user:, track:)

          stub_latest_track_forum_threads(track)

          metric = Metric::Create.('start_solution', Time.current, solution:, track:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            MetricsChannel.broadcast!(metric)

            assert_text "A user started"
            assert_text solution.exercise.title
          end
        end

        test "user sees open_pull_request activity" do
          user = create :user
          track = create :track, title: "Ruby"
          create(:user_track, user:, track:)
          pr = create :github_pull_request, repo: track.repo_url

          stub_latest_track_forum_threads(track)

          metric = Metric::Create.('open_pull_request', Time.current, pull_request: pr, track:, user:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            MetricsChannel.broadcast!(metric)

            assert_text user.handle
            assert_text "submitted a Pull Request on Exercism's GitHub"
          end
        end

        test "user sees merge_pull_request activity" do
          user = create :user
          track = create :track, title: "Ruby"
          create(:user_track, user:, track:)
          pr = create :github_pull_request, repo: track.repo_url

          stub_latest_track_forum_threads(track)

          metric = Metric::Create.('merge_pull_request', Time.current, pull_request: pr, track:, user:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            MetricsChannel.broadcast!(metric)

            assert_text user.handle
            assert_text "had a Pull Request merged on Exercism's GitHub"
          end
        end
      end
    end
  end
end
