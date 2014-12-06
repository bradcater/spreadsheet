$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestAbsCell < Minitest::Test
  # If the Spreadsheet is:
  # 1 -2 =ABS((0,0)) =ABS((0,1))
  # Then it should produce:
  # 1 -2 1           2
  def setup
    @spreadsheet = Spreadsheet.new(:rows => 1, :cols => 4)
    @spreadsheet.set_cell(0, 0, 1)
    @spreadsheet.set_cell(0, 1, -2)
    @spreadsheet.set_cell(0, 2, '=ABS((0,0))')
    @spreadsheet.set_cell(0, 3, '=ABS((0,1))')
  end

  def test_get_value
    assert_equal(1, @spreadsheet.get_cell(0, 2))
    assert_equal(2, @spreadsheet.get_cell(0, 3))
  end
end
