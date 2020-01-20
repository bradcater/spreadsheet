class Node
  attr_accessor :name, :edges
  def initialize(name)
    @name = name
    @edges = []
  end
  def add_edge(e)
    unless e.from_node == self
      raise 'Cannot add an edge that does not start from here.'
    end
    @edges << e
  end
  def remove_edge(e) ; @edges -= [e] ; end
  def to_s ; name ; end
end
