require "test_helper"

class Track
  class DetermineConceptsLayoutTest < ActiveSupport::TestCase
    def test_layout_empty
      assert_equal [], DetermineConceptsLayout.(TestData::CONFIG_EMPTY)[:levels]
    end

    def test_layout_small
      assert_equal(
        [[2], [0, 1]],
        DetermineConceptsLayout.(TestData::CONFIG_SMALL)[:levels].
          map { |layer| layer.map(&:index) }
      )
    end

    module TestData
      CONFIG_EMPTY = { 'language' => 'test', 'exercises' => [] }.freeze

      CONFIG_SMALL = {
        'language' => 'elixir',
        'exercises' => [
          {
            'slug' => 'booleans',
            'uuid' => '5e743355-1ef3-4b5d-b59d-03bbc9697e6c',
            'concepts' => %w[booleans],
            'prerequisites' => %w[basics]
          },
          {
            'slug' => 'numbers',
            'uuid' => 'fee79e03-1496-476f-964f-e60632cb13dc',
            'concepts' => %w[integers floating-point-numbers],
            'prerequisites' => %w[basics booleans]
          },
          {
            'slug' => 'basics',
            'uuid' => 'c29c6092-9d44-4f21-8138-b873384fd90b',
            'concepts' => %w[basics],
            'prerequisites' => []
          }
        ]
      }.freeze
    end
  end
end
