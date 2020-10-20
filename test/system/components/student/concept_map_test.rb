require "application_system_test_case"

module Components
  module Student
    class ConceptMapTest < ApplicationSystemTestCase
      def setup
        super

        # This component uses the API, which requires authentication.
        sign_in!
      end

      test "renders concept map for joined track" do
        # TODO: Unskip once this issue is resolved:
        # https://github.com/exercism/v3-website/issues/143
        skip

        track = create :track, title: "Ruby"
        create :user_track, track: track, user: @current_user
        basics, booleans, atoms = setup_concepts(track, 'basics', 'booleans', 'atoms')
        lasagna, pacman, logger = setup_concept_exercises(track, 'lasagna', 'pacman', 'logger')

        lasagna.taught_concepts << basics
        pacman.taught_concepts << booleans
        pacman.prerequisites << basics
        logger.taught_concepts << atoms
        logger.prerequisites << booleans

        visit tracks_url
        click_link "Ruby"
        click_on "Concepts" # <-- this click_on fails

        expect(page).to have_content 'Basics'
        expect(page).to have_content 'Booleans'
        expect(page).to have_content 'Atoms'
      end

      private
      def setup_user_track
        track = create :track
        user_track = create :user_track, track: track

        [track, user_track]
      end

      def setup_concepts(track, *slugs)
        setup_from_factory(track, :track_concept, slugs)
      end

      def setup_concept_exercises(track, *slugs)
        setup_from_factory(track, :concept_exercise, slugs)
      end

      def setup_from_factory(track, type, slugs)
        slugs.map { |slug| create type, slug: slug, track: track }
      end
    end
  end
end
