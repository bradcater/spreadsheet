$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestMinCell < Minitest::Test
  # If the Spreadsheet is:
  # 1 2 3 =MIN((0,0),(0,1)) =MIN((0,0),(0,1),(0,2))
  # Then it should produce:
  # 1 2 3 1                 1
  def setup
    @spreadsheet = Spreadsheet.new(:rows => 1, :cols => 5)
    @spreadsheet.set_cell(0, 0, 1)
    @spreadsheet.set_cell(0, 1, 2)
    @spreadsheet.set_cell(0, 2, 3)
    @spreadsheet.set_cell(0, 3, '=MIN((0,0),(0,1))')
    @spreadsheet.set_cell(0, 4, '=MIN((0,0),(0,1),(0,2))')
  end

  def test_get_value
    assert_equal(1, @spreadsheet.get_cell(0, 3))
    assert_equal(1, @spreadsheet.get_cell(0, 4))
  end
end
