require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  class UserViewsProfileTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows the three most starred published solutions" do
      # If we let this run then we need valid git filepaths
      # for all of the stub exercises below, so we stub it
      Solution::QueueHeadTestRun.stubs(:defer)

      author = create :user
      create :user_profile, user: author
      ruby = create :track, title: "Ruby"

      { "Strings" => 8, "Running" => 5, "Bob" => 3, "Leap" => 1 }.each do |title, num_stars|
        exercise = create(:concept_exercise, track: ruby, slug: title.downcase, title:)
        solution = create(:concept_solution, exercise:, user: author, published_at: 1.day.ago, num_stars:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)
      end

      use_capybara_host do
        visit profile_path(author.handle)

        within('.published-solutions-section') do
          assert_text "Strings"
          assert_text "Running"
          assert_text "Bob"

          # Only the top 3 by stars are shown
          assert_no_text "Leap"
        end
      end
    end

    test "shows only revealed badges" do
      author = create :user
      create :user_profile, user: author
      create :user_acquired_badge, user: author, badge: create(:member_badge), revealed: true
      create :user_acquired_badge, user: author, badge: create(:rookie_badge), revealed: false
      create :user_acquired_badge, user: author, badge: create(:supporter_badge), revealed: true

      use_capybara_host do
        visit profile_path(author.handle)

        assert_text "2 badges collected"
        within('.badges') do
          assert_selector('.c-badge', count: 2)
          assert_selector("img[alt='Badge: Member']")
          refute_selector("img[alt='Badge: Rookie']")
          assert_selector("img[alt='Badge: Supporter']")
        end
      end
    end

    test "shows (escaped) bio" do
      author = create :user, bio: 'Programming is my passion! <img src="x">'
      create :user_profile, user: author

      use_capybara_host do
        visit profile_path(author.handle)

        assert_text author.bio
      end
    end
  end
end
