require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/markdown_editor_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class MentoringRepGateTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include MarkdownEditorHelpers
    include RedirectHelpers

    test "show progress bar if reputation is not enough to mentor" do
      user = create :user, :not_mentor, reputation: 19

      use_capybara_host do
        sign_in!(user)
        visit Exercism::Routes.mentoring_url
        assert_text "Ability to mentor unlocks at"
      end
    end

    test "show button if reputation is enough to mentor" do
      user = create :user, :not_mentor, reputation: 20

      use_capybara_host do
        sign_in!(user)
        visit Exercism::Routes.mentoring_url
        assert_text "Try mentoring now"
      end
    end
  end
end
