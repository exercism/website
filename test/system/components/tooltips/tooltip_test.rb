require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Tooltips
    class TooltipTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentored student tooltip renders correctly" do
        # Create these first so they have the first two ids
        create :user, handle: 'mentee'
        create :user, handle: 'someone-else'

        use_capybara_host do
          sign_in!
          visit test_components_tooltips_tooltip_path

          mentored_students = all('ol.mentored-students > li')

          mentored_students[0].hover
          within(".c-student-tooltip") { assert_text "mentee" }
        end
      end

      test "user tooltip renders correctly" do
        # Create these first so they have the first two ids
        create :user, handle: 'mentee', name: 'Erik ShireBOOM'

        use_capybara_host do
          sign_in!
          visit test_components_tooltips_tooltip_path

          users = all('ol.users > li')

          users[0].hover
          within(".c-user-tooltip") { assert_text "Erik ShireBOOM" }
        end
      end
    end
  end
end
