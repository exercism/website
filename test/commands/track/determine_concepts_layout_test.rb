require 'test_helper'

class Track
  class DetermineConceptMapLayoutTest < ActiveSupport::TestCase
    def test_layout_empty_level
      track = create :track
      user_track = create(:user_track, track:)

      assert_equal(
        {
          concepts: [],
          levels: [],
          connections: []
        },
        Track::DetermineConceptMapLayout.(user_track)
      )
    end

    def test_layout_with_one_level
      track = create :track
      user_track = create(:user_track, track:)

      basics = create(:concept, slug: 'basics', track:)

      lasagna = create(:concept_exercise, track:)
      lasagna.taught_concepts << basics

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/basics/tooltip'
            }
          ],
          levels: [['basics']],
          connections: []
        },
        Track::DetermineConceptMapLayout.(user_track)
      )
    end

    def test_layout_with_two_levels
      track = create :track
      user_track = create(:user_track, track:)

      basics = create(:concept, slug: 'basics', track:)
      booleans = create(:concept, slug: 'booleans', track:)

      lasagna = create(:concept_exercise, track:)
      lasagna.taught_concepts << basics

      pacman = create(:concept_exercise, track:)
      pacman.taught_concepts << booleans
      pacman.prerequisites << basics

      assert_equal(
        {
          concepts: [
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans/tooltip'
            }
          ],
          levels: [['basics'], ['booleans']],
          connections: [{ from: 'basics', to: 'booleans' }]
        },
        Track::DetermineConceptMapLayout.(user_track)
      )
    end

    def test_layout_with_three_level
      track = create :track
      user_track = create(:user_track, track:)

      basics = create(:concept, slug: 'basics', track:)
      booleans = create(:concept, slug: 'booleans', track:)
      atoms = create(:concept, slug: 'atoms', track:)

      lasagna = create(:concept_exercise, track:)
      lasagna.taught_concepts << basics

      pacman = create(:concept_exercise, track:)
      pacman.taught_concepts << booleans
      pacman.prerequisites << basics

      logger = create(:concept_exercise, track:)
      logger.taught_concepts << atoms
      logger.prerequisites << booleans

      assert_equal(
        {
          concepts: [
            {
              slug: 'atoms',
              name: 'Atoms',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/atoms',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/atoms/tooltip'
            },
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans/tooltip'
            }
          ],
          levels: [['basics'], ['booleans'], ['atoms']],
          connections: [{ from: 'basics', to: 'booleans' }, { from: 'booleans', to: 'atoms' }]
        },
        Track::DetermineConceptMapLayout.(user_track)
      )
    end

    def test_layout_with_three_level_multiple_prereq
      track = create :track
      user_track = create(:user_track, track:)

      basics = create(:concept, slug: 'basics', track:)
      booleans = create(:concept, slug: 'booleans', track:)
      atoms = create(:concept, slug: 'atoms', track:)

      lasagna = create(:concept_exercise, track:)
      lasagna.taught_concepts << basics

      pacman = create(:concept_exercise, track:)
      pacman.taught_concepts << booleans
      pacman.prerequisites << basics

      logger = create(:concept_exercise, track:)
      logger.taught_concepts << atoms
      logger.prerequisites << basics # while this is a prereq, it should not generate edge
      logger.prerequisites << booleans

      assert_equal(
        {
          concepts: [
            {
              slug: 'atoms',
              name: 'Atoms',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/atoms',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/atoms/tooltip'
            },
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans/tooltip'
            }
          ],
          levels: [['basics'], ['booleans'], ['atoms']],
          connections: [{ from: 'basics', to: 'booleans' }, { from: 'booleans', to: 'atoms' }]
        },
        Track::DetermineConceptMapLayout.(user_track)
      )
    end

    def test_layout_with_three_level_multiple_prereq_and_taught
      track = create :track
      user_track = create(:user_track, track:)

      basics = create(:concept, slug: 'basics', track:)
      booleans = create(:concept, slug: 'booleans', track:)
      atoms = create(:concept, slug: 'atoms', track:)
      cond = create(:concept, slug: 'cond', track:)

      lasagna = create(:concept_exercise, track:)
      lasagna.taught_concepts << basics

      pacman = create(:concept_exercise, track:)
      pacman.taught_concepts << booleans
      pacman.taught_concepts << atoms
      pacman.prerequisites << basics

      logger = create(:concept_exercise, track:)
      logger.taught_concepts << cond
      logger.prerequisites << booleans
      logger.prerequisites << atoms

      assert_equal(
        {
          concepts: [
            {
              slug: 'atoms',
              name: 'Atoms',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/atoms',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/atoms/tooltip'
            },
            {
              slug: 'basics',
              name: 'Basics',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/basics',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/basics/tooltip'
            },
            {
              slug: 'booleans',
              name: 'Booleans',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/booleans/tooltip'
            },
            {
              slug: 'cond',
              name: 'Cond',
              web_url: 'https://test.exercism.org/tracks/ruby/concepts/cond',
              tooltip_url: 'https://test.exercism.org/tracks/ruby/concepts/cond/tooltip'
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
        Track::DetermineConceptMapLayout.(user_track)
      )
    end

    def test_open_issue_when_prerequisite_cycle_found
      track = create :track
      user_track = create(:user_track, track:)

      numbers = create(:concept, slug: 'numbers', track:)
      booleans = create(:concept, slug: 'booleans', track:)

      pacman = create(:concept_exercise, track:)
      pacman.taught_concepts << booleans
      pacman.prerequisites << numbers

      logger = create(:concept_exercise, track:)
      logger.taught_concepts << numbers
      logger.prerequisites << booleans

      assert_enqueued_with job: MandateJob, args: [Github::Issue::OpenForDependencyCycle.name, user_track.track] do
        assert_raises TrackHasCyclicPrerequisiteError do
          Track::DetermineConceptMapLayout.(user_track)
        end
      end
    end

    def test_raises_error_when_prerequisite_cycle_found
      track = create :track
      user_track = create(:user_track, track:)

      numbers = create(:concept, slug: 'numbers', track:)
      booleans = create(:concept, slug: 'booleans', track:)

      pacman = create(:concept_exercise, track:)
      pacman.taught_concepts << booleans
      pacman.prerequisites << numbers

      logger = create(:concept_exercise, track:)
      logger.taught_concepts << numbers
      logger.prerequisites << booleans

      assert_raises TrackHasCyclicPrerequisiteError do
        Track::DetermineConceptMapLayout.(user_track)
      end
    end
  end
end
