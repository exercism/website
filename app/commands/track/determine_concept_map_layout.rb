require 'graph_utils'

# ConceptGraph transforms a track configuration to a form compatible for manipulating for
# displaying the progression of the track
class Track::DetermineConceptMapLayout
  include Mandate

  def initialize(user_track)
    @user_track = user_track
    @graph = Graph.new(user_track)
  end

  # Layout computes the ordering of the exercises in a track by creating
  # a graph then traversing it to discover and memoize the progression
  def call
    {
      concepts:,
      levels: concept_levels,
      connections: concept_connections
    }
  rescue TrackHasCyclicPrerequisiteError
    Github::Issue::OpenForDependencyCycle.defer(user_track.track)
    raise
  end

  private
  attr_reader :user_track, :graph

  memoize
  def concepts
    concepts = graph.nodes.flat_map do |concept|
      {
        slug: concept.slug,
        name: concept.name,
        web_url: Exercism::Routes.track_concept_url(user_track.track.slug, concept.slug),
        tooltip_url: Exercism::Routes.tooltip_track_concept_url(user_track.track.slug, concept.slug)
      }
    end

    concepts.sort_by { |concept| concept[:slug] }.freeze
  end

  memoize
  def concept_levels
    node_levels.map { |level| level.map(&:slug) }.freeze
  end

  memoize
  def concept_connections
    node_levels.drop(1).flat_map.with_index do |level, level_idx|
      level.flat_map do |node|
        node.prerequisites.
          map { |prerequisite| graph.node_for_concept(prerequisite) }.
          compact.
          select { |prerequisite_node| prerequisite_node.level == level_idx }.
          map { |prerequisite_node| { from: prerequisite_node.slug, to: node.slug } }
      end
    end
  end

  memoize
  def node_levels
    return [] if graph.empty?

    raise TrackHasCyclicPrerequisiteError if graph.has_cycle?

    Array.new(graph.concept_levels.max + 1) { [] }.tap do |level|
      graph.concept_levels.each.with_index do |level_idx, node_idx|
        node = graph.node_for_index(node_idx)
        node.level = level_idx

        level[level_idx] << node
      end
    end
  end

  class Graph
    include Mandate

    attr_reader :nodes

    # Edge representing a directed edge
    Edge = Struct.new(:from, :to, keyword_init: true)

    # Node for representing an exercise within a track
    Node = Struct.new(:index, :slug, :name, :prerequisites, :level, keyword_init: true)

    def initialize(user_track)
      @user_track = user_track
      @nodes = determine_nodes
      @edges = determine_edges
    end

    memoize
    def empty? = nodes.empty? # rubocop:disable Rails/Delegate

    memoize
    def has_cycle?
      GraphUtils.contains_cycle?(adjacencies)
    end

    def node_for_concept(concept)
      nodes_keyed_by_concept[concept]
    end

    def node_for_index(index)
      nodes_keyed_by_index[index]
    end

    memoize
    def concept_levels
      GraphUtils.calculate_levels(adjacencies)
    end

    private
    attr_reader :edges, :user_track

    # Creates adjacency list for a graph with directed edges
    memoize
    def adjacencies
      Array.new(nodes.length) { [] }.tap do |adjacencies|
        edges.each do |edge|
          from = edge.from.index
          to = edge.to.index
          adjacencies[from] << to
        end
      end
    end

    def determine_nodes
      nodes = user_track.concept_exercises.includes(:taught_concepts, :prerequisites).flat_map do |exercise|
        exercise.taught_concepts.map do |concept|
          Node.new(
            index: nil,
            slug: concept.slug,
            name: concept.name,
            prerequisites: exercise.prerequisites.pluck(:slug)
          )
        end
      end

      nodes.each.with_index { |node, idx| node.index = idx }.freeze
    end

    def determine_edges
      nodes.flat_map do |node|
        node.prerequisites.map do |prereq|
          prereq_node = node_for_concept(prereq)
          prereq_node ? Edge.new(from: prereq_node, to: node) : nil
        end
      end.compact.freeze
    end

    memoize
    def nodes_keyed_by_concept
      nodes.index_by(&:slug).freeze
    end

    memoize
    def nodes_keyed_by_index
      nodes.index_by(&:index).freeze
    end
  end
end
