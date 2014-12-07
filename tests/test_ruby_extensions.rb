$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestRubyExtensions < Minitest::Test
  def test_array_left
    assert_equal([], [].left)
    assert_equal([1], [1].left)
    assert_equal([1], [1, 2].left)
    assert_equal([1], [1, 2, 3].left)
    assert_equal([1, 2], [1, 2, 3, 4].left)
    assert_equal([1, 2], [1, 2, 3, 4, 5].left)
  end

  def test_array_mean
    [:average, :mean].each do |m|
      assert_equal(nil, [].send(m))
      assert_equal(1, [1].send(m))
      assert_equal(1.5, [1, 2].send(m))
      assert_equal(2, [1, 2, 3].send(m))
    end
  end

  def test_array_right
    assert_equal([], [].right)
    assert_equal([], [1].right)
    assert_equal([2], [1, 2].right)
    assert_equal([2, 3], [1, 2, 3].right)
    assert_equal([3, 4], [1, 2, 3, 4].right)
    assert_equal([3, 4, 5], [1, 2, 3, 4, 5].right)
  end

  def test_array_product
    assert_equal(nil, [].product)
    assert_equal(2, [2].product)
    assert_equal(6, [2, 3].product)
    assert_equal(24, [2, 3, 4].product)
    assert_equal(120, [2, 3, 4, 5].product)
    assert_equal(720, [2, 3, 4, 5, 6].product)
  end

  def test_array_sum
    assert_equal(0, [].sum)
    assert_equal(1, [1].sum)
    assert_equal(3, [1, 2].sum)
  end

  def test_nil_blank
    assert_equal(true, nil.blank?)
  end

  def test_nil_present
    assert_equal(false, nil.present?)
  end

  def test_object_blank
    assert_equal(false, Object.new.blank?)
  end

  def test_object_present
    assert_equal(true, Object.new.present?)
  end

  def test_nil_try
    assert_equal(nil, nil.try(:+, 1))
  end

  def test_object_try
    assert_equal(true, Object.new.try(:present?))
  end

  def test_blank
    assert_equal(true, ''.blank?)
    assert_equal(true, ' '.blank?)
    assert_equal(false, 'abc'.blank?)
  end

  def test_first
    assert_equal('A', 'A'.first)
    assert_equal('A', 'ABC'.first)
  end

  def test_last
    assert_equal('A', 'A'.last)
    assert_equal('C', 'ABC'.last)
  end

  def test_string_pad_to_width
    assert_equal('abc', 'abc'.pad_to_width(3))
    assert_equal('def ', 'def'.pad_to_width(4))
    assert_equal('ghi   ', 'ghi'.pad_to_width(6))
  end
end
