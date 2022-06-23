require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsTrackTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows about information" do
      track = create :track

      use_capybara_host do
        visit track_path(track)

        assert_text "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity."
      end
    end

    test "shows key features" do
      track = create :track

      use_capybara_host do
        visit track_path(track)

        assert_text "Modern"
        assert_text "Ruby is a modern, object-oriented language."

        assert_text "Fun"
        assert_text "Ruby is fun to use!"

        assert_text "Full-featured"
        assert_text "Ruby is packed with built-in useful stuff."

        assert_text "Easy to learn"
        assert_text "Ruby is easy to learn."

        assert_text "Dynamic"
        assert_text "Ruby is very dynamic."

        assert_text "Expressive"
        assert_text "Ruby code can be very expressive."
      end
    end

    test "shows concepts preview if track has course" do
      track = create :track, course: true

      use_capybara_host do
        visit track_path(track)

        assert_text "A taste of the concepts you’ll cover"
      end
    end

    test "does not show concepts preview if track does not have course" do
      track = create :track, course: false

      use_capybara_host do
        visit track_path(track)

        refute_text "A taste of the concepts you’ll cover"
      end
    end
  end
end
