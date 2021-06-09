require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Contributing
    class UserViewsTasksListTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views tasks list" do
        create :github_task, title: "Fix bug"

        use_capybara_host do
          visit contributing_tasks_path

          assert_text "Fix bug"
        end
      end

      test "user filters by track" do
        ruby = create :track, slug: "ruby"
        go = create :track, slug: "go"
        create :github_task, title: "Fix bug", track: ruby
        create :github_task, title: "Write docs", track: go

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All"
          find("label", text: "Go").click

          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by action" do
        create :github_task, title: "Fix bug", action: :fix
        create :github_task, title: "Write docs", action: :improve

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All actions"
          find("label", text: "Improve").click
          find("body").click

          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end
    end
  end
end
