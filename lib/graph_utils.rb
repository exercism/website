# Collection of graph utilities for manipulating and traversing graphs
module GraphUtils
  # Creates adjacency list for a graph with directed edges
  def self.make_adjacency_list(graph)
    blank_adjacency = Array.new(graph.nodes.length) { [] }
    graph.edges.each_with_object(blank_adjacency) do |edge, memo_adjacency|
      from = edge.from.index
      to = edge.to.index
      memo_adjacency[from] << to
    end
  end

  # Examines the graph structure (through an adjacency list) looking
  # for a cycle
  def self.contains_cycle?(adjacency)
    visited = Array.new(adjacency.length).fill(false)
    on_stack = Array.new(adjacency.length).fill(false)
    stack = []

    # Check from each node in the case of disjunct graphs
    0.upto(adjacency.length - 1).each do |source|
      next if visited[source]

      stack << source

      # Loop until the stack is empty
      until stack.empty?
        n = stack.last

        if !visited[n]
          visited[n] = true
          on_stack[n] = true
        else
          on_stack[n] = false
          stack.pop
        end

        adjacency[n].each do |adjacent_node|
          if !visited[adjacent_node]
            stack << adjacent_node
          elsif on_stack[adjacent_node]
            # A cycle has been found
            return true
          end
        end
      end
    end

    false
  end

  # From an adjacency list, find the number of incoming edges to a node (the in-degree)
  def self.find_indegree(adjacency)
    blank_indegrees = Array.new(adjacency.length) { 0 }
    adjacency.each_with_object(blank_indegrees) do |adj_nodes, indegrees|
      adj_nodes.each_with_object(indegrees) do |adj_node, indegrees|
        indegrees[adj_node] += 1
      end
    end
  end

  # From a list of in-degrees, where the index represents a node index,
  # determine the sources (roots) of the graph where the in-degree is 0
  def self.find_sources(indegrees)
    indegrees.each_with_index.filter { |indegree, _| indegree.zero? }.map { |_, index| index }
  end

  # Assign a depth to all nodes in the graph
  # The node is assigned the depth when it is encountered on the max-length route
  def self.find_depths(source_nodes, adjacency)
    max_depths = Array.new(adjacency.length).fill(0)

    stack = source_nodes.map { |source_index| [source_index, 0] }
    until stack.empty?
      node_index, depth = stack.pop
      max_depths[node_index] = depth if depth > max_depths[node_index]
      adjacency[node_index].each { |child| stack << [child, depth + 1] }
    end

    max_depths
  end
end
