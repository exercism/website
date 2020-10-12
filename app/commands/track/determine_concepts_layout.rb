require 'graph_utils'

# ConceptGraph transforms a track configuration to a form compatible for manipulating for
# displaying the progression of the track
class Track
  class DetermineConceptsLayout
    include Mandate

    def initialize(track_config)
      @graph = Graph.new(track_config['exercises'])
    end

    # Layout computes the ordering of the exercises in a track by creating
    # a graph then traversing it to discover and memoize the progression
    def call
      {
        levels: levels,
        connections: connections
      }
    end

    private
    attr_reader :graph

    memoize
    def levels
      return [] if graph.empty?

      raise TrackHasCyclicPrerequisiteError if graph.has_cycle?

      Array.new(graph.levels.max + 1) { [] }.tap do |level|
        graph.levels.each.with_index do |level_idx, node_idx|
          node = graph.node_for_index(node_idx)
          node.level = level_idx

          level[level_idx] << node
        end
      end
    end

    memoize
    def connections
      levels.drop(1).each.with_index.flat_map do |level, level_idx|
        level.flat_map do |node|
          node.prerequisites.
            map { |prerequisite| graph.node_for_concept(prerequisite) }.
            compact.
            uniq.
            select { |prerequisite_node| prerequisite_node.level == level_idx }.
            map { |prerequisite_node| { from: prerequisite_node.slug, to: node.slug } }
        end
      end
    end

    class Graph
      include Mandate

      # Edge representing a directed edge
      Edge = Struct.new(:from, :to, keyword_init: true)

      # Node for representing an exercise within a track
      Node = Struct.new(:index, :slug, :uuid, :concepts, :prerequisites, :level, keyword_init: true)

      def initialize(exercises)
        @exercises = exercises
        @nodes = determine_nodes
        @edges = determine_edges
      end

      memoize
      def empty?
        nodes.empty?
      end

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
      def levels
        GraphUtils.calculate_levels(adjacencies)
      end

      private
      attr_reader :nodes, :edges, :exercises

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
        exercises.map.with_index do |exercise, idx|
          Node.new(
            index: idx,
            slug: exercise['slug'],
            uuid: exercise['uuid'],
            concepts: exercise['concepts'],
            prerequisites: exercise['prerequisites']
          )
        end.freeze
      end

      def determine_edges
        nodes.flat_map do |node|
          node.prerequisites.map do |prereq|
            prereq_node = node_for_concept(prereq)
            Edge.new(from: prereq_node, to: node) unless prereq_node.nil?
          end
        end.freeze
      end

      memoize
      def nodes_keyed_by_concept
        nodes.flat_map do |node|
          node.concepts.map { |concept| [concept, node] }
        end.to_h.freeze
      end

      memoize
      def nodes_keyed_by_index
        nodes.index_by(&:index).freeze
      end
    end
  end
end
