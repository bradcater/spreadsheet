$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestStaticCell < Minitest::Test
  def test_number
    assert_equal(true, StaticCell.number?('1'))
    assert_equal(true, StaticCell.number?('1.0'))
    assert_equal(true, StaticCell.number?('-1'))
    assert_equal(true, StaticCell.number?('-1.0'))
    assert_equal(false, StaticCell.number?(''))
    assert_equal(false, StaticCell.number?('abc'))
  end

  def test_string
    assert_equal(false, StaticCell.string?('1'))
    assert_equal(false, StaticCell.string?('1.0'))
    assert_equal(false, StaticCell.string?('-1'))
    assert_equal(false, StaticCell.string?('-1.0'))
    assert_equal(true, StaticCell.string?(''))
    assert_equal(true, StaticCell.string?('abc'))
  end
end
