require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsConceptMakersTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows concept makers" do
      track = create :track
      concept = create :concept, track: track
      author = create :user, handle: "ConceptAuthor"
      contributor = create :user, handle: "ConceptContributor"
      create :concept_authorship, concept: concept, author: author
      create :concept_contributorship, concept: concept, contributor: contributor

      use_capybara_host do
        visit track_concept_path(track, concept)

        click_on "1 author"

        assert_text "ConceptAuthor"
        assert_text "ConceptContributor"
      end
    end
  end
end
