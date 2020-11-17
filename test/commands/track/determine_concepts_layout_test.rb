require 'test_helper'

class Track
  class DetermineConceptMapLayoutTest < ActiveSupport::TestCase
    def test_layout_empty_level
      track = create :track
      assert_equal(
        {
          concepts: [],
          levels: [],
          connections: []
        },
        Track::DetermineConceptMapLayout.(track)
      )
    end

    def test_layout_with_one_level
      track = create :track

      basics = create :track_concept, slug: 'basics', track: track

      lasagna = create :concept_exercise, track: track
      lasagna.taught_concepts << basics

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/basics/tooltip'
            }
          ],
          levels: [['basics']],
          connections: []
        },
        Track::DetermineConceptMapLayout.(track)
      )
    end

    def test_layout_with_two_levels
      track = create :track

      basics = create :track_concept, slug: 'basics', track: track
      booleans = create :track_concept, slug: 'booleans', track: track

      lasagna = create :concept_exercise, track: track
      lasagna.taught_concepts << basics

      pacman = create :concept_exercise, track: track
      pacman.taught_concepts << booleans
      pacman.prerequisites << basics

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans/tooltip'
            }
          ],
          levels: [['basics'], ['booleans']],
          connections: [{ from: 'basics', to: 'booleans' }]
        },
        Track::DetermineConceptMapLayout.(track)
      )
    end

    def test_layout_with_three_level
      track = create :track

      basics = create :track_concept, slug: 'basics', track: track
      booleans = create :track_concept, slug: 'booleans', track: track
      atoms = create :track_concept, slug: 'atoms', track: track

      lasagna = create :concept_exercise, track: track
      lasagna.taught_concepts << basics

      pacman = create :concept_exercise, track: track
      pacman.taught_concepts << booleans
      pacman.prerequisites << basics

      logger = create :concept_exercise, track: track
      logger.taught_concepts << atoms
      logger.prerequisites << booleans

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans/tooltip'
            },
            {
              slug: 'atoms',
              name: 'Atoms',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/atoms',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/atoms/tooltip'
            }
          ],
          levels: [['basics'], ['booleans'], ['atoms']],
          connections: [{ from: 'basics', to: 'booleans' }, { from: 'booleans', to: 'atoms' }]
        },
        Track::DetermineConceptMapLayout.(track)
      )
    end

    def test_layout_with_three_level_multiple_prereq
      track = create :track

      basics = create :track_concept, slug: 'basics', track: track
      booleans = create :track_concept, slug: 'booleans', track: track
      atoms = create :track_concept, slug: 'atoms', track: track

      lasagna = create :concept_exercise, track: track
      lasagna.taught_concepts << basics

      pacman = create :concept_exercise, track: track
      pacman.taught_concepts << booleans
      pacman.prerequisites << basics

      logger = create :concept_exercise, track: track
      logger.taught_concepts << atoms
      logger.prerequisites << basics # while this is a prereq, it should not generate edge
      logger.prerequisites << booleans

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans/tooltip'
            },
            {
              slug: 'atoms',
              name: 'Atoms',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/atoms',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/atoms/tooltip'
            }
          ],
          levels: [['basics'], ['booleans'], ['atoms']],
          connections: [{ from: 'basics', to: 'booleans' }, { from: 'booleans', to: 'atoms' }]
        },
        Track::DetermineConceptMapLayout.(track)
      )
    end

    def test_layout_with_three_level_multiple_prereq_and_taught
      track = create :track

      basics = create :track_concept, slug: 'basics', track: track
      booleans = create :track_concept, slug: 'booleans', track: track
      atoms = create :track_concept, slug: 'atoms', track: track
      cond = create :track_concept, slug: 'cond', track: track

      lasagna = create :concept_exercise, track: track
      lasagna.taught_concepts << basics

      pacman = create :concept_exercise, track: track
      pacman.taught_concepts << booleans
      pacman.taught_concepts << atoms
      pacman.prerequisites << basics

      logger = create :concept_exercise, track: track
      logger.taught_concepts << cond
      logger.prerequisites << booleans
      logger.prerequisites << atoms

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/booleans/tooltip'
            },
            {
              slug: 'atoms',
              name: 'Atoms',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/atoms',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/atoms/tooltip'
            },
            {
              slug: 'cond',
              name: 'Cond',
              web_url: 'https://test.exercism.io/tracks/ruby/concepts/cond',
              tooltip_url: 'https://test.exercism.io/tracks/ruby/concepts/cond/tooltip'
            }
          ],
          levels: [%w[basics], %w[booleans atoms], %w[cond]],
          connections: [
            { from: 'basics', to: 'booleans' },
            { from: 'basics', to: 'atoms' },
            { from: 'booleans', to: 'cond' },
            { from: 'atoms', to: 'cond' }
          ]
        },
        Track::DetermineConceptMapLayout.(track)
      )
    end
  end
end
