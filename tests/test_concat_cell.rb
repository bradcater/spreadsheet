$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestConcatCell < Minitest::Test
  # If the Spreadsheet is:
  # 'A' 'B' 'C' =CONCAT((0,0),(0,1)) =CONCAT((0,0),(0,1),(0,2))
  # Then it should produce:
  # 'A' 'B' 'C' 'AB'                 'ABC'
  def setup
    @spreadsheet = Spreadsheet.new(:rows => 1, :cols => 5)
    @spreadsheet.set_cell(0, 0, 'A')
    @spreadsheet.set_cell(0, 1, 'B')
    @spreadsheet.set_cell(0, 2, 'C')
    @spreadsheet.set_cell(0, 3, '=CONCAT((0,0),(0,1))')
    @spreadsheet.set_cell(0, 4, '=CONCAT((0,0),(0,1),(0,2))')
  end

  def test_get_value
    assert_equal('AB', @spreadsheet.get_cell(0, 3))
    assert_equal('ABC', @spreadsheet.get_cell(0, 4))
  end
end
