require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class MentorRegistrationTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "show progress bar if reputation is not enough to mentor" do
      user = create :user, :not_mentor, reputation: User::MIN_REP_TO_MENTOR - 1

      use_capybara_host do
        sign_in!(user)
        visit Exercism::Routes.mentoring_url
        assert_text "Ability to mentor unlocks at"
      end
    end

    test "registers to be a mentor" do
      stub_request(:post, "https://dev.null.exercism.io/")

      user = create :user, :not_mentor, reputation: User::MIN_REP_TO_MENTOR
      create :track, title: "Ruby"

      use_capybara_host do
        sign_in!(user)
        visit mentoring_path
        click_on "Try mentoring now"
        find("label", text: "Ruby").click
        within(".m-become-mentor") { click_on "Continue" }

        find("label", text: "Abide by the\nCode of Conduct").click
        find("label", text: "Be patient, empathic and kind to those you're mentoring").click
        find("label", text: "Demonstrate\nintellectual humility").find(".c-checkbox").click # TODO: simplify
        find("label", text: "Not use Exercism to promote personal agendas").click
        within(".m-become-mentor") { click_on "Continue" }
        click_on "I'm ready to get started"

        assert_text "Ruby"
      end
    end
  end
end
