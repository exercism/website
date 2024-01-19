require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module TrackMenu
      class SeesActivityTickerTest < ApplicationSystemTestCase
        include CapybaraHelpers

        setup do
          Geocoder::Lookup::Test.add_stub(
            "133.200.0.160",
            [{ 'country_code' => 'JP', 'country' => 'Japan', 'coordinates' => [35.6837, 139.6805] }]
          )

          @user = create :user
          @track = create :track, title: "Ruby"
          create(:hello_world_exercise, track: @track)
          @exercise = create(:concept_exercise, track: @track)
          create(:user_track, user: @user, track: @track)

          @request_context = { remote_ip: "133.200.0.160" }

          stub_latest_track_forum_threads(@track)
        end

        test "user sees submit_submission activity" do
          submission = create :submission

          metric = Metric::Create.('submit_submission', Time.current, submission:, track: @track, request_context: @request_context)

          use_capybara_host do
            sign_in!(@user)
            visit track_url(@track)
            MetricsChannel.broadcast!(metric)

            assert_text "Someone in Japan attempted"
            assert_text submission.exercise.title
          end
        end

        test "user sees publish_solution activity" do
          solution = create(:practice_solution, :published, exercise: @exercise, user: @user)

          metric = Metric::Create.('publish_solution', Time.current, solution:, track: @track, user: @user,
            request_context: @request_context)

          use_capybara_host do
            sign_in!(@user)
            visit track_url(@track)
            MetricsChannel.broadcast!(metric)

            assert_text @user.handle
            assert_text "published a new solution for"
            assert_text solution.exercise.title
          end
        end

        test "user sees complete_solution activity" do
          submission = create :submission
          iteration = create(:iteration, submission:)

          metric = Metric::Create.('complete_solution', Time.current, solution: iteration, track: @track, user: @user,
            request_context: @request_context)

          use_capybara_host do
            sign_in!(@user)
            visit track_url(@track)
            MetricsChannel.broadcast!(metric)

            assert_text "Someone in Japan completed"
            assert_text submission.exercise.title
          end
        end

        test "user sees start_solution activity" do
          skip
          # TODO: Add a solution that fits
          solution = create(:practice_solution, user: @user, track: @track)

          metric = Metric::Create.('start_solution', Time.current, solution:, track: @track, request_context: @request_context)

          use_capybara_host do
            sign_in!(@user)
            visit track_url(@track)
            MetricsChannel.broadcast!(metric)

            assert_text "Someone started"
            assert_text solution.exercise.title
          end
        end

        test "user sees open_pull_request activity" do
          pr = create :github_pull_request, repo: @track.repo_url

          metric = Metric::Create.('open_pull_request', Time.current, pull_request: pr, track: @track, user: @user,
            request_context: @request_context)

          use_capybara_host do
            sign_in!(@user)
            visit track_url(@track)
            MetricsChannel.broadcast!(metric)

            assert_text @user.handle
            assert_text "opened a Pull Request"
          end
        end

        test "user sees merge_pull_request activity" do
          pr = create :github_pull_request, repo: @track.repo_url

          metric = Metric::Create.('merge_pull_request', Time.current, pull_request: pr, track: @track, user: @user,
            request_context: @request_context)

          use_capybara_host do
            sign_in!(@user)
            visit track_url(@track)
            MetricsChannel.broadcast!(metric)

            assert_text @user.handle
            assert_text "merged a Pull Request"
          end
        end
      end
    end
  end
end
