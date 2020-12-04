require "application_system_test_case"

module Components
  module Tooltips
    class TooltipTest < ApplicationSystemTestCase
      test "mentored student tooltip renders correctly" do
        visit test_components_tooltips_tooltip_path

        mentored_students = all('ol.mentored-students > li')

        mentored_students[0].hover
        within(".c-mentored-student-tooltip") { assert_text "mentee" }

        mentored_students[1].hover
        within(".c-mentored-student-tooltip") { assert_text "User 2" }
      end

      test "user tooltip renders correctly" do
        visit test_components_tooltips_tooltip_path

        users = all('ol.users > li')

        users[0].hover
        within(".c-user-tooltip") { assert_text "Erik Schierboom" }

        # users[1].hover
        # within(".c-user-tooltip") { assert_text "Rob Keim" }
      end
    end
  end
end
