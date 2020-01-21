class Graph
  attr_accessor :nodes
  def initialize
    @nodes = []
  end
  def add_node(n)
    n.edges.each do |e|
      [e.from_node, e.to_node].each do |edge_node|
        unless nodes.any?{|existing_node| edge_node == existing_node}
          puts "WARNING: #{edge_node} is not in the graph."
        end
      end
    end
    @nodes << n
  end
  def remove_node(n)
    @nodes -= [n]
    nodes.each do |node|
      node.edges.select do |e|
        e.from_node == n || e.to_node == n
      end.each do |e|
        node.remove_edge(e)
      end
    end
  end
  def acyclic? ; !cyclic? ; end
  def cyclic?
    nodes.each do |n|
      found_node = visit(n, Set.new([n]))
      return true if found_node
    end
    false
  end
  # dfs
  def visit(n, visited)
    n.edges.each do |e|
      return e.to_node if visited.include?(e.to_node)
      found_node = visit(e.to_node, visited + Set.new([e.to_node]))
      return found_node if found_node
    end
    nil
  end
end
