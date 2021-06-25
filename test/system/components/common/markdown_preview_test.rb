require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Components
  module Common
    class MarkdownPreviewTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include MarkdownEditorHelpers

      # TODO: This needs to be contextual, so show the
      # mentoring markdown options when in mentoring mode
      test "user sees markdown preview" do
        use_capybara_host do
          sign_in!
          visit test_components_common_markdown_editor_path
          fill_in_editor "## Hello"
          find('button.preview').click

          assert_selector "h4", text: "Hello"
        end
      end
    end
  end
end
