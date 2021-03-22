require "test_helper"
require 'graph_utils'

class GraphUtilsTest < ActiveSupport::TestCase
  def test_detect_cycles
    assert GraphUtils.contains_cycle?([[1], [0]])
    assert GraphUtils.contains_cycle?([[1], [2], [0]])
    assert GraphUtils.contains_cycle?([[1], [2], [3], [1]])

    refute GraphUtils.contains_cycle?([[1], []])
    refute GraphUtils.contains_cycle?([[1], [2], []])
    refute GraphUtils.contains_cycle?([[2], [], [1]])
  end

  def test_find_indegree
    assert_equal [0, 1], GraphUtils.find_indegree([[1], []])
  end

  def test_find_sources
    assert_empty GraphUtils.find_sources([])
    assert_empty GraphUtils.find_sources([1, 1])
    assert_equal [0, 3], GraphUtils.find_sources([0, 1, 3, 0])
  end

  def test_find_depths
    sources = [1]
    adjacency = [[], [2], [0]]
    assert_equal [2, 0, 1], GraphUtils.find_depths(sources, adjacency)
  end

  def test_find_depths_node_with_prereq_at_different_levels
    sources = [1, 3]
    adjacency = [[], [2], [0], [0]]
    assert_equal [2, 0, 1, 0], GraphUtils.find_depths(sources, adjacency)
  end
end
