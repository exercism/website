require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class MentorRegistrationTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "registers to be a mentor" do
      user = create :user, :not_mentor
      create :track, title: "Ruby"

      use_capybara_host do
        sign_in!(user)
        visit mentoring_path
        click_on "Try mentoring now"
        find("label", text: "Ruby").click
        click_on "Continue"
        find("label", text: "Abide by the\nCode of Conduct").click
        find("label", text: "Be patient, empathic and kind to those you're mentoring").click
        find("label", text: "Demonstrate\nintellectual humility").click(x: 0, y: 0)
        find("label", text: "Not use Exercism to promote personal agendas").click
        click_on "Continue"
        click_on "I'm ready to get started"

        assert_text "Ruby"
      end
    end
  end
end
