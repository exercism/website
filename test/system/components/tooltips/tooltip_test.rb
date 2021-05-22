require "application_system_test_case"

module Components
  module Tooltips
    class TooltipTest < ApplicationSystemTestCase
      test "mentored student tooltip renders correctly" do
        # Create these first so they have the first two ids
        create :user, handle: 'mentee'
        create :user, handle: 'someone-else'

        sign_in!
        visit test_components_tooltips_tooltip_path

        mentored_students = all('ol.mentored-students > li')

        mentored_students[0].hover
        within(".c-student-tooltip") { assert_text "mentee" }
      end

      test "user tooltip renders correctly" do
        # Create these first so they have the first two ids
        create :user, handle: 'mentee', name: 'Erik ShireBOOM'

        sign_in!
        visit test_components_tooltips_tooltip_path

        users = all('ol.users > li')

        users[0].hover
        within(".c-user-tooltip") { assert_text "Erik ShireBOOM" }
      end
    end
  end
end
