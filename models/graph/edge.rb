class Edge
  attr_accessor :from_node, :to_node
  def initialize(from_node, to_node)
    @from_node = from_node
    @to_node = to_node
  end
end
