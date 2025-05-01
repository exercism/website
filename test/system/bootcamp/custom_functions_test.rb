require_relative "base_test"

module Bootcamp
  class EditorTest < BaseTest
    test "things render" do
      user = create(:user, bootcamp_attendee: true)

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_custom_functions_url

        find("#new-function-button").click

        assert_selector(".c-toggle-button")
        assert_button("Dependencies")
        assert_button("Save Changes")
        assert_button("Delete")
        assert_link("Close")
        assert_button("Add new test")
        assert_text("Function name")
        assert_text("Description")
        assert_text("Tests")
        assert_button("Check code")
      end
    end
  end
end
