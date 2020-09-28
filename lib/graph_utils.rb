# Collection of graph utilities for manipulating and traversing graphs
module GraphUtils
  def self.calculate_levels(adjacencies)
    find_indegree(adjacencies).
      then { |indegrees| find_sources(indegrees) }.
      then { |sources| find_depths(sources, adjacencies) }
  end

  # Examines the graph structure (through an adjacencies list) looking
  # for a cycle
  def self.contains_cycle?(adjacencies)
    visited = Array.new(adjacencies.length).fill(false)
    on_stack = Array.new(adjacencies.length).fill(false)
    stack = []

    # Check from each node in the case of disjunct graphs
    0.upto(adjacencies.length - 1).each do |source|
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

        adjacencies[n].each do |adjacent_node|
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

  # From an adjacencies list, find the number of incoming edges to a node (the in-degree)
  def self.find_indegree(adjacencies)
    Array.new(adjacencies.length) { 0 }.tap do |indegrees|
      adjacencies.each do |adj_nodes|
        adj_nodes.each do |adj_node|
          indegrees[adj_node] += 1
        end
      end
    end
  end

  # From a list of in-degrees, where the index represents a node index,
  # determine the sources (roots) of the graph where the in-degree is 0
  def self.find_sources(indegrees)
    indegrees.each_with_index.
      filter { |indegree, _| indegree.zero? }.
      map { |_, idx| idx }
  end

  # Assign a depth to all nodes in the graph
  # The node is assigned the depth when it is encountered on the max-length route
  def self.find_depths(source_nodes, adjacencies)
    max_depths = Array.new(adjacencies.length).fill(0)

    stack = source_nodes.map { |source_index| [source_index, 0] }
    until stack.empty?
      node_index, depth = stack.pop
      max_depths[node_index] = depth if depth > max_depths[node_index]
      adjacencies[node_index].each { |child| stack << [child, depth + 1] }
    end

    max_depths
  end
end
