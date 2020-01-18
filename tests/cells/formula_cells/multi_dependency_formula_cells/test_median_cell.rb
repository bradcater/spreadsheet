$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestMedianCell < Minitest::Test
  # If the Spreadsheet is:
  # 1 2 3 =MEDIAN((0,0),(0,1)) =MEDIAN((0,0),(0,1),(0,2))
  # Then it should produce:
  # 1 2 3 2                    2
  def setup
    @spreadsheet = Spreadsheet.new(:rows => 1, :cols => 5)
    @spreadsheet.set_cell(0, 0, 1)
    @spreadsheet.set_cell(0, 1, 2)
    @spreadsheet.set_cell(0, 2, 3)
    @spreadsheet.set_cell(0, 3, '=MEDIAN((0,0),(0,1))')
    @spreadsheet.set_cell(0, 4, '=MEDIAN((0,0),(0,1),(0,2))')
  end

  def test_get_value
    assert_equal(2, @spreadsheet.get_cell(0, 3))
    assert_equal(2, @spreadsheet.get_cell(0, 4))
  end
end
