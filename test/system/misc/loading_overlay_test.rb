require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/markdown_editor_helpers"

module Misc
  class LoadingOverlayTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include MarkdownEditorHelpers

    test "shows and hides loading overlay" do
      use_capybara_host do
        sign_in!
        visit test_misc_loading_overlay_path
        click_on "Redirect"

        assert_css ".c-loading-overlay.--loading"
        assert_text "Welcome to Exercism's docs"
        assert_no_css ".c-loading-overlay.--loading"
      end
    end
  end
end
