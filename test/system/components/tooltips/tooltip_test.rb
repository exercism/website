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

      test "user summary tooltip renders correctly" do
        visit test_components_tooltips_tooltip_path

        user_summaries = all('ol.user-summaries > li')

        user_summaries[0].hover
        within(".c-user-summary-tooltip") { assert_text "Erik Schierboom" }

        # user_summaries[1].hover
        # within(".c-user-summary-tooltip") { assert_text "Rob Keim" }
      end
    end
  end
end
