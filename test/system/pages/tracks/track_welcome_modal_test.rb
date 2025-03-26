require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Pages
  module Tracks
    class TrackWelcomeModalTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include RedirectHelpers

      setup do
        @user = create :user
        @track = create :track
        create(:hello_world_exercise, track: @track)
        create(:user_track, track: @track, user: @user)
        stub_latest_track_forum_threads(@track)
      end

      test "user sees track welcome modal with learning mode" do
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)

          assert_text "Welcome to #{@track.title}!"
          assert_selector '[data-capy-element="welcome-modal-track-info"]'
          assert_text "Here to learn or practice?"
          assert_text "Learning Mode"
          assert_text "Practice Mode"
        end
      end

      test "user sees track welcome modal without learning mode" do
        @track.update(course: false)
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)

          assert_text "Welcome to #{@track.title}!"
          assert_text "You'll be in Practice Mode"
          assert_text 'Continue'
        end
      end

      test "user doesnt see track welcome modal after completed tutorial exercise" do
        create(:hello_world_solution, :completed, user: @user, track: @track)

        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)

          refute_text "Welcome to #{@track.title}!"
          refute_text "Here to learn or practice?"
        end
      end

      test "user sees correct embedded video on track with learning mode" do
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)

          assert_selector 'iframe[src*="903381063?h=bb0a6316bf"]'
        end
      end

      test "user sees correct embedded video on track with practice mode" do
        @track.update(course: false)
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)

          assert_selector "iframe[src*='903384161?h=91c7b9a795']"
        end
      end

      test "user visits each distinct page" do
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)

          assert_text "Here to learn or practice?"
          click_on "Learning Mode"
          assert_text "Online or on your computer?"
          click_on "In the online editor"
          assert_text "You're all set"
          assert_text "If you change your mind later and want to work in your own environment"
          click_on 'Reset choices'
          assert_text "Here to learn or practice?"
          click_on "Practice Mode"
          assert_text "Online or on your computer?"
          click_on "On my local machine"
          assert_text "Let's get coding"
        end
      end

      test "old user sees bootcamp recommendation page if beginner" do
        use_capybara_host do
          @user.reload
          @user.update!(seniority: :beginner, created_at: 10.days.ago)

          sign_in!(@user)
          visit track_path(@track)

          assert_text "Here to learn or practice?"
          click_on "Learning Mode"
          assert_selector '[data-capy-element="bootcamp-recommendation-header"]'
          # assert if rhs is rendered correctly
          assert_selector '[data-capy-element="who-is-this-track-for-rhs"]'
        end
      end

      test "new user doesn't see bootcamp recommendation page if beginner" do
        use_capybara_host do
          @user.reload
          @user.update!(seniority: :beginner)

          sign_in!(@user)
          visit track_path(@track)

          assert_text "Here to learn or practice?"
          click_on "Learning Mode"
          refute_selector '[data-capy-element="bootcamp-recommendation-header"]'
          # assert if rhs is rendered correctly
          refute_selector '[data-capy-element="who-is-this-track-for-rhs"]'
        end
      end

      test "user can go to bootcamp landing" do
        use_capybara_host do
          @user.reload
          @user.update!(seniority: :beginner, created_at: 10.days.ago)

          sign_in!(@user)
          visit track_path(@track)

          assert_text "Here to learn or practice?"
          click_on "Practice Mode"
          assert_selector '[data-capy-element="bootcamp-recommendation-header"]'
          find(:css, '[data-capy-element="go-to-bootcamp-button"]').click
          assert_current_path Exercism::Routes.course_path('coding-fundamentals')
        end
      end

      test "user can dismiss bootcamp recommendation" do
        use_capybara_host do
          @user.reload
          @user.update!(seniority: :beginner, created_at: 10.days.ago)

          sign_in!(@user)
          visit track_path(@track)

          assert_text "Here to learn or practice?"
          click_on "Practice Mode"
          assert_selector '[data-capy-element="bootcamp-recommendation-header"]'
          find(:css, '[data-capy-element="continue-anyway-button"]').click
          refute_selector '[data-capy-element="bootcamp-recommendation-header"]'
          assert_text "Online or on your computer?"
          refute_selector '[data-capy-element="who-is-this-track-for-rhs"]'
        end
      end

      test "pages contain the correct links" do
        @track.update(course: false)
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)
          assert_equal Exercism::Routes.track_doc_url(@track, 'learning'), find_link('these supplementary resources')[:href]
          click_on "Continue"
          click_on "On my local machine"
          assert_equal Exercism::Routes.cli_walkthrough_url, find_link('Exercism\'s CLI')[:href]
          assert_equal Exercism::Routes.track_doc_url(@track, 'installation'), find_link("#{@track.title}'s tooling")[:href]
        end
      end

      test "choosing editor redirects you to hello world in editor" do
        @track.update(course: false)
        create :hello_world_exercise
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)
          click_on "Continue"
          click_on "In the online editor"

          Exercism.without_bullet do
            click_on "Continue to online editor"

            wait_for_redirect
            assert_current_path Exercism::Routes.edit_track_exercise_path(@track, 'hello-world')
          end
        end
      end

      test "choosing local closes modal correctly" do
        @track.update(course: false)
        create :hello_world_exercise
        use_capybara_host do
          sign_in!(@user.reload)
          visit track_path(@track)
          click_on "Continue"
          click_on "On my local machine"
          click_on "Continue"
          refute_text "Let's get coding"
        end
      end
    end
  end
end
