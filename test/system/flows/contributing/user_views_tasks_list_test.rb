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

      test "user views task tooltip" do
        track = create :track, title: "Ruby"
        create :github_task,
          track:,
          action: "create",
          type: "docs",
          size: "large",
          knowledge: "intermediate",
          area: "test-runner"

        use_capybara_host do
          visit contributing_tasks_path
          find(".task").hover

          assert_text "For this task you will be creating Test Runner docs for the Ruby Track."
          assert_text "This task involves writing docs."
          assert_text "This task requires you to create something new."
          assert_text "This is a large task."
          assert_text "This task requires intermediate Exercism knowledge."
          assert_text "This task is about Test Runners."
        end
      end

      test "user filters by track" do
        ruby = create :track, slug: "ruby"
        go = create :track, slug: "go"
        create :github_task, title: "Fix bug", track: ruby
        create :github_task, title: "Write docs", track: go

        use_capybara_host do
          visit contributing_tasks_path
          click_on "All Tracks"
          find("label", text: "Go").click

          assert_text "Showing 1 task / out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by action" do
        create :github_task, title: "Fix bug", action: :fix
        create :github_task, title: "Write docs", action: :improve

        use_capybara_host do
          visit contributing_tasks_path
          click_button "Action"
          find("label", text: "Improve").click
          find("label", text: "Improve").native.send_keys(:tab)

          assert_text "Showing 1 task / out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by types" do
        create :github_task, title: "Fix bug", type: :coding
        create :github_task, title: "Write docs", type: :docs

        use_capybara_host do
          visit contributing_tasks_path
          click_button "Type"
          find("label", text: "Docs").click
          find("label", text: "Docs").native.send_keys(:tab)

          assert_text "Showing 1 task / out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by size" do
        create :github_task, title: "Fix bug", size: :tiny
        create :github_task, title: "Write docs", size: :medium

        use_capybara_host do
          visit contributing_tasks_path
          click_button "Size"
          find("label", text: "Medium").click
          find("label", text: "Medium").native.send_keys(:tab)

          assert_text "Showing 1 task / out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by knowledge" do
        create :github_task, title: "Fix bug", knowledge: :none
        create :github_task, title: "Write docs", knowledge: :intermediate

        use_capybara_host do
          visit contributing_tasks_path
          click_button "Knowledge"
          find("label", text: "Intermediate").click
          find("label", text: "Intermediate").native.send_keys(:tab)

          assert_text "Showing 1 task / out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user filters by module" do
        create :github_task, title: "Fix bug", area: "test-runner"
        create :github_task, title: "Write docs", area: :generator

        use_capybara_host do
          visit contributing_tasks_path
          click_button "Module"
          find("label", text: "Generator").click
          find("label", text: "Generator").native.send_keys(:tab)

          assert_text "Showing 1 task / out of 2 possible tasks"
          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user resets filters" do
        create :github_task, title: "Fix bug", area: "test-runner"
        create :github_task, title: "Write docs", area: :generator

        use_capybara_host do
          visit contributing_tasks_path
          click_button "Module"
          find("label", text: "Generator").click
          find("label", text: "Generator").native.send_keys(:tab)
          click_on "Reset Filters"

          assert_text "Write docs"
          assert_text "Fix bug"
        end
      end

      test "user orders tasks" do
        Github::Task::Search.stubs(:requests_per_page).returns(1)
        ruby = create :track, slug: "ruby"
        go = create :track, slug: "go"
        create :github_task, title: "Fix bug", track: ruby
        create :github_task, title: "Write docs", track: go

        use_capybara_host do
          visit contributing_tasks_path
          click_on "Sort by most recent"
          find("label", text: "Sort by track").click

          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end

      test "user switches pages" do
        Github::Task::Search.stubs(:requests_per_page).returns(1)
        create :github_task, title: "Fix bug"
        create :github_task, title: "Write docs"

        use_capybara_host do
          visit contributing_tasks_path
          within(".c-pagination") { click_on "2" }

          assert_text "Write docs"
          assert_no_text "Fix bug"
        end
      end
    end
  end
end
