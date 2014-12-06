$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestSubCell < Minitest::Test
  # If the Spreadsheet is:
  # 1 2 =SUB((0,1),(0,0))
  # Then it should produce:
  # 1 2 1
  def setup
    @spreadsheet = Spreadsheet.new(:rows => 1, :cols => 3)
    @spreadsheet.set_cell(0, 0, 1)
    @spreadsheet.set_cell(0, 1, 2)
    @spreadsheet.set_cell(0, 2, '=SUB((0,1),(0,0))')
  end

  def test_get_value
    assert_equal(1, @spreadsheet.get_cell(0, 2))
  end
end
