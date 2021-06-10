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

          assert_text "Showing 1 task out of 2 possible tasks"
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

          assert_text "Showing 1 task out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by types" do
        create :github_task, title: "Fix bug", type: :coding
        create :github_task, title: "Write docs", type: :docs

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All types"
          find("label", text: "Docs").click
          find("body").click(x: 0, y: 0)

          assert_text "Showing 1 task out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by size" do
        create :github_task, title: "Fix bug", size: :tiny
        create :github_task, title: "Write docs", size: :medium

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All sizes"
          find("label", text: "Medium").click
          find("body").click(x: 0, y: 0)

          assert_text "Showing 1 task out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by knowledge" do
        create :github_task, title: "Fix bug", knowledge: :none
        create :github_task, title: "Write docs", knowledge: :intermediate

        use_capybara_host do
          visit contributing_tasks_path
          click_on "Any knowledge"
          find("label", text: "Intermediate").click
          find("body").click(x: 0, y: 0)

          assert_text "Showing 1 task out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by module" do
        create :github_task, title: "Fix bug", area: "test-runner"
        create :github_task, title: "Write docs", area: :generator

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All modules"
          find("label", text: "Generator").click
          find("body").click(x: 0, y: 0)

          assert_text "Showing 1 task out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user resets filters" do
        create :github_task, title: "Fix bug", area: "test-runner"
        create :github_task, title: "Write docs", area: :generator

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All modules"
          find("label", text: "Generator").click
          find("body").click(x: 0, y: 0)
          click_on "Reset Filters"

          assert_text "Write docs"
          assert_text "Fix bug"
        end
      end

      test "user switches pages" do
        Github::Task::Search.stubs(:requests_per_page).returns(1)
        create :github_task, title: "Fix bug"
        create :github_task, title: "Write docs"

        use_capybara_host do
          visit contributing_tasks_path
          click_on "2"

          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end
    end
  end
end
