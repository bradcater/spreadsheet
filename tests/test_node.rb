$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestNode < Minitest::Test
  def test_name
    a = Node.new('a')
    assert_equal 'a', a.name
  end

  def test_to_s
    a = Node.new('a')
    assert_equal 'a', a.to_s
  end

  def test_checks_valid_edges
    a = Node.new('a')
    b = Node.new('b')
    exception = assert_raises(RuntimeError) do
      a.add_edge(Edge.new(b, a))
    end
    assert_equal('Cannot add an edge that does not start from here.', exception.message)
  end
end
