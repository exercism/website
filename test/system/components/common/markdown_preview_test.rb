require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Common
    class MarkdownPreviewTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user sees markdown preview" do
        use_capybara_host do
          sign_in!
          visit test_components_common_markdown_editor_path
          fill_in_editor "# Hello"
          find('button.preview').click

          assert_selector "h1", text: "Hello"
        end
      end

      def fill_in_editor(text)
        execute_script("document.querySelector('.CodeMirror').CodeMirror.setValue('#{text}')")
      end
    end
  end
end
