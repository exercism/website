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
    end
  end
end
