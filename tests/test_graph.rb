$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestGraph < Minitest::Test
  def test_graph_add_and_remove_nodes
    g = Graph.new
    assert_equal [], g.nodes
    a = Node.new('a')
    b = Node.new('b')
    g.add_node(a)
    assert_equal [a], g.nodes
    g.add_node(b)
    assert_equal [a, b], g.nodes
    g.remove_node(b)
    assert_equal [a], g.nodes
    g.remove_node(a)
    assert_equal [], g.nodes
  end

  def test_empty_graph_acyclic_and_cyclic
    g = Graph.new
    assert_equal true, g.acyclic?
    assert_equal false, g.cyclic?
  end

  def test_single_node_cyclic_graph_acyclic_and_cyclic
    g = Graph.new
    a = Node.new('a')
    g.add_node(a)
    assert_equal true, g.acyclic?
    assert_equal false, g.cyclic?
    a.add_edge(Edge.new(a, a))
    assert_equal false, g.acyclic?
    assert_equal true, g.cyclic?
  end

  def test_simple_graph_acyclic_and_cyclic
    g = Graph.new
    a = Node.new('a')
    b = Node.new('b')
    a.add_edge(Edge.new(a, b))
    assert_equal true, g.acyclic?
    assert_equal false, g.cyclic?
  end

  #   b
  #  /|\
  # a | d
  #  \|  \ # e -> d. All other edges point down and to the right.
  #   c - e
  def test_complex_acyclic_graph_acyclic_and_cyclic
    g = Graph.new
    a = Node.new('a')
    b = Node.new('b')
    c = Node.new('c')
    d = Node.new('d')
    e = Node.new('e')
    a.add_edge(Edge.new(a, b))
    a.add_edge(Edge.new(a, c))
    b.add_edge(Edge.new(b, c))
    b.add_edge(Edge.new(b, d))
    c.add_edge(Edge.new(c, d))
    c.add_edge(Edge.new(c, e))
    e.add_edge(Edge.new(e, d))
    g.add_node(a)
    g.add_node(b)
    g.add_node(c)
    g.add_node(d)
    g.add_node(e)
    assert_equal true, g.acyclic?
    assert_equal false, g.cyclic?
  end

  #   b   f
  #  /|\ /|
  # a | d |
  #  \|  \|  # e -> d. All other edges point down or to the right.
  #   c - e
  def test_complex_cyclic_graph_acyclic_and_cyclic
    g = Graph.new
    a = Node.new('a')
    b = Node.new('b')
    c = Node.new('c')
    d = Node.new('d')
    e = Node.new('e')
    f = Node.new('f')
    a.add_edge(Edge.new(a, b))
    a.add_edge(Edge.new(a, c))
    b.add_edge(Edge.new(b, c))
    b.add_edge(Edge.new(b, d))
    c.add_edge(Edge.new(c, d))
    c.add_edge(Edge.new(c, e))
    e.add_edge(Edge.new(e, d))
    d.add_edge(Edge.new(d, f))
    f.add_edge(Edge.new(f, e))
    g.add_node(a)
    g.add_node(b)
    g.add_node(c)
    g.add_node(d)
    g.add_node(e)
    g.add_node(f)
    assert_equal false, g.acyclic?
    assert_equal true, g.cyclic?
  end
end
