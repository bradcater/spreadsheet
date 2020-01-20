class Graph
  attr_accessor :nodes
  def initialize
    @nodes = []
  end
  def add_node(n) ; @nodes << n ; end
  def remove_node(n) ; @nodes -= [n] ; end
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
