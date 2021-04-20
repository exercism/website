require 'graph_utils'

# ConceptGraph transforms a track configuration to a form compatible for manipulating for
# displaying the progression of the track
class Track
  class DetermineConceptMapLayout
    include Mandate

    def initialize(track)
      @track = track
      @graph = Graph.new(track)
    end

    # Layout computes the ordering of the exercises in a track by creating
    # a graph then traversing it to discover and memoize the progression
    def call
      {
        concepts: concepts,
        levels: concept_levels,
        connections: concept_connections
      }
    end

    private
    attr_reader :track, :graph

    memoize
    def concepts
      concepts = graph.nodes.flat_map do |exercise|
        exercise.taught_concepts.map do |concept|
          {
            slug: concept.slug,
            name: concept.name,
            web_url: Exercism::Routes.track_concept_url(track, concept),
            tooltip_url: Exercism::Routes.tooltip_track_concept_url(track, concept)
          }
        end
      end

      concepts.sort_by { |concept| concept[:slug] }
    end

    memoize
    def concept_levels
      exercise_levels.map { |level| level.flat_map(&:taught_concepts).map(&:slug) }
    end

    memoize
    def concept_connections
      exercise_connections.flat_map do |connection|
        from_concepts = connection[:from].taught_concepts
        to_concepts = connection[:to].taught_concepts

        from_concepts.product(to_concepts).map do |(from, to)|
          { from: from.slug, to: to.slug }
        end
      end
    end

    memoize
    def exercise_levels
      return [] if graph.empty?

      raise TrackHasCyclicPrerequisiteError if graph.has_cycle?

      Array.new(graph.exercise_levels.max + 1) { [] }.tap do |level|
        graph.exercise_levels.each.with_index do |level_idx, node_idx|
          node = graph.node_for_index(node_idx)
          node.level = level_idx

          level[level_idx] << node
        end
      end
    end

    memoize
    def exercise_connections
      exercise_levels.drop(1).each.with_index.flat_map do |level, level_idx|
        level.flat_map do |node|
          node.prerequisites.
            map { |prerequisite| graph.node_for_concept(prerequisite) }.
            compact.
            uniq.
            select { |prerequisite_node| prerequisite_node.level == level_idx }.
            map { |prerequisite_node| { from: prerequisite_node, to: node } }
        end
      end
    end

    class Graph
      include Mandate

      attr_reader :nodes

      # Edge representing a directed edge
      Edge = Struct.new(:from, :to, keyword_init: true)

      # Node for representing an exercise within a track
      Node = Struct.new(:index, :slug, :taught_concepts, :prerequisites, :level, keyword_init: true)

      def initialize(track)
        @track = track
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
      def exercise_levels
        GraphUtils.calculate_levels(adjacencies)
      end

      private
      attr_reader :edges, :track

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
        track.concept_exercises.includes(:taught_concepts, :prerequisites).map.with_index do |exercise, idx|
          Node.new(
            index: idx,
            slug: exercise.slug,
            taught_concepts: exercise.taught_concepts.to_a,
            prerequisites: exercise.prerequisites.to_a
          )
        end.freeze
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
        nodes.flat_map do |node|
          node.taught_concepts.map { |concept| [concept, node] }
        end.to_h.freeze
      end

      memoize
      def nodes_keyed_by_index
        nodes.index_by(&:index).freeze
      end
    end
  end
end
