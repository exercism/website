require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Pages
  module Tracks
    module Concepts
      class IndexTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "renders correctly" do
          track = create :track
          user = create :user
          create(:user_track, track:, user:)

          basics = create(:concept, slug: 'basics', track:)
          booleans = create(:concept, slug: 'booleans', track:)
          atoms = create(:concept, slug: 'atoms', track:)

          lasagna = create(:concept_exercise, track:)
          lasagna.taught_concepts << basics

          pacman = create(:concept_exercise, track:)
          pacman.taught_concepts << booleans
          pacman.taught_concepts << atoms
          pacman.prerequisites << basics

          use_capybara_host do
            sign_in!(user)

            visit track_concepts_url(track)
          end
        end
      end
    end
  end
end
