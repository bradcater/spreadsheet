$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestEdge < Minitest::Test
  def test_accessors
    a = Node.new('a')
    b = Node.new('b')
    e = Edge.new(a, b)
    assert_equal a, e.from_node
    assert_equal b, e.to_node
  end
end
