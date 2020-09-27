require 'graph_utils'

# ConceptGraph transforms a track configuration to a form compatible for manipulating for
# displaying the progression of the track
class Track
  class DetermineConceptsLayout
    include Mandate

    attr_reader(
      :language,
      :nodes,
      :edges,
      :node_lookup_by_concept,
      :node_lookup_by_index,
      :adjacency,
      :has_cycle
    )

    def initialize(track_config)
      @language = track_config['language']
      @nodes = make_nodes(track_config['exercises'])
      @node_lookup_by_concept = make_concept_lookup
      @node_lookup_by_index = make_index_lookup
      @edges = make_edges
      @adjacency = GraphUtils.make_adjacency_list(self)
      @has_cycle = GraphUtils.contains_cycle?(adjacency)
    end

    # Layout computes the ordering of the exercises in a track by creating
    # a graph then traversing it to discover and memoize the progression
    def call
      return [] if nodes.empty?
      return :error if has_cycle

      node_indegrees = GraphUtils.find_indegree(adjacency)
      source_nodes = GraphUtils.find_sources(node_indegrees)
      exercise_depths = GraphUtils.find_depths(source_nodes, adjacency)

      blank_layout = Array.new(exercise_depths.max + 1) { [] }
      exercise_depths.each_with_index.each_with_object(blank_layout) do |(depth, index), layers|
        layers[depth] << node_lookup_by_index[index]
      end
    end

    private
    def make_nodes(exercises)
      exercises.each_with_index.reduce([]) do |a, (exercise, i)|
        a << Node.new(
          index: i,
          slug: exercise['slug'],
          uuid: exercise['uuid'],
          concepts: exercise['concepts'],
          prerequisites: exercise['prerequisites']
        )
      end.freeze
    end

    def make_concept_lookup
      nodes.each_with_object({}) do |node, lookup|
        node.concepts.each { |concept| lookup[concept] = node }
      end.freeze
    end

    def make_index_lookup
      nodes.index_by(&:index).freeze
    end

    def make_edges
      nodes.each_with_object([]) do |node, aggregate|
        node.prerequisites.each_with_object(aggregate) do |prereq, a|
          prereq_node = node_lookup_by_concept[prereq]
          a << Edge.new(from: prereq_node, to: node) unless prereq_node.nil?
        end
      end.freeze
    end

    #
    # Supporting Graph Classes
    #

    # Edge representing a directed edge
    class Edge
      attr_reader :from, :to

      def initialize(from:, to:)
        @from = from
        @to = to
      end
    end

    # Node for representing an exercise within a track
    class Node
      attr_reader :index, :slug, :concepts, :prerequisites

      def initialize(index:, slug:, uuid:, concepts:, prerequisites:)
        @index = index
        @slug = slug
        @uuid = uuid
        @concepts = concepts.reduce([]) { |a, concept| a << concept.dup }
        @prerequisites = prerequisites.reduce([]) { |a, prereq| a << prereq.dup }
      end
    end
  end
end
