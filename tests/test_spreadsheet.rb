$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestSpreadsheet < Minitest::Test
  def setup
    @spreadsheet = Spreadsheet.new(:rows => 4, :columns => 5)
  end

  def test_get_rows
    assert_equal(4, @spreadsheet.get_row_count)
  end

  def test_get_columns
    assert_equal(5, @spreadsheet.get_column_count)
  end

  def test_add_row
    assert_equal(4, @spreadsheet.get_row_count)
    @spreadsheet.add_row
    assert_equal(5, @spreadsheet.get_row_count)
  end

  def test_add_column
    assert_equal(5, @spreadsheet.get_column_count)
    @spreadsheet.add_column
    assert_equal(6, @spreadsheet.get_column_count)
  end

  def test_set_and_get_cell
    @spreadsheet.set_cell(1, 2, 5)
    assert_equal(5, @spreadsheet.get_cell(1, 2))
  end

  def test_set_and_clear_cell
    @spreadsheet.set_cell(0, 0, 10)
    assert_equal(10, @spreadsheet.get_cell(0, 0))
    @spreadsheet.clear_cell(0, 0)
    assert_equal(nil, @spreadsheet.get_cell(0, 0))
  end

  def test_dependencies
    # 1 -2 =SUM((0,0),(0,1)) =SUM((0,0),(0,2))
    # 1 -2 -1                0
    @spreadsheet.set_cell(0, 0, 1)
    @spreadsheet.set_cell(0, 1, -2)
    @spreadsheet.set_cell(0, 2, '=SUM((0,0),(0,1))')
    @spreadsheet.set_cell(0, 3, '=SUM((0,0),(0,2))')
    assert_equal(-1, @spreadsheet.get_cell(0, 2))
    assert_equal(0, @spreadsheet.get_cell(0, 3))
    # 1 -2 =SUB((0,1),(0,0)) =SUM((0,0),(0,2))
    # 1 -2 -3                -2
    @spreadsheet.set_cell(0, 2, '=SUB((0,1),(0,0))')
    assert_equal(-3, @spreadsheet.get_cell(0, 2))
    assert_equal(-2, @spreadsheet.get_cell(0, 3))
    # 1 -2 =ABS((0,1)) =SUM(0,0),(0,2))
    # 1 -2 2           3
    @spreadsheet.set_cell(0, 2, '=ABS((0,1))')
    assert_equal(2, @spreadsheet.get_cell(0, 2))
    assert_equal(3, @spreadsheet.get_cell(0, 3))
  end

  def test_more_dependencies
    # interest        0.07              1.0               =SUM((0,1),(0,2)) nil
    # principle       10000.0           4                 nil               nil
    # quarterly_int_m =DIV((0,1),(1,2)) =SUM((0,2),(2,1)) nil               nil
    # after_1_quarter 10175.0           nil               nil               nil
    @spreadsheet.set_cell(0, 0, 'interest')
    @spreadsheet.set_cell(0, 1, 0.07)
    @spreadsheet.set_cell(0, 2, 1.0)
    @spreadsheet.set_cell(0, 3, '=SUM((0,1),(0,2))')
    assert_equal(1.07, @spreadsheet.get_cell(0, 3))
    @spreadsheet.set_cell(1, 0, 'principle')
    @spreadsheet.set_cell(1, 1, 10_000)
    @spreadsheet.set_cell(1, 2, 4)
    @spreadsheet.set_cell(2, 0, 'quarterly_int_m')
    @spreadsheet.set_cell(2, 1, '=DIV((0,1),(1,2))')
    @spreadsheet.set_cell(2, 2, '=SUM((0,2),(2,1))')
    @spreadsheet.set_cell(3, 0, 'after_1_quarter')
    @spreadsheet.set_cell(3, 1, '=PROD((1,1),(2,2))')
    assert_equal(10_175, @spreadsheet.get_cell(3, 1))
    # interest        0.075             1.0               =SUM((0,1),(0,2)) nil
    # principle       10000.0           4                 nil               nil
    # quarterly_int_m =DIV((0,1),(1,2)) =SUM((0,2),(2,1)) nil               nil
    # after_1_quarter 10175.0           nil               nil               nil
    @spreadsheet.set_cell(0, 1, 0.075)
    assert_equal(1.075, @spreadsheet.get_cell(0, 3))
    assert_equal(10_187.5, @spreadsheet.get_cell(3, 1))
  end

  def test_can_set_formula_cell
    # 1 2 =SUM((0,0),(0,1))
    # 1 2 3
    @spreadsheet.set_cell(0, 0, 1)
    @spreadsheet.set_cell(0, 1, 2)
    @spreadsheet.set_cell(0, 2, '=SUM((0,0),(0,1))')
    assert_equal(3, @spreadsheet.get_cell(0, 2))
    # 1 2 =SUM((0,0),(0,1)) =SUM((0,2),(0,3))
    exception = assert_raises(RuntimeError) do
      @spreadsheet.set_cell(0, 3, '=SUM((0,2),(0,3))')
    end
    assert_equal('A FormulaCell cannot refer to itself.', exception.message)
  end
end
