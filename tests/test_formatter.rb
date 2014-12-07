$:<< '.'

load 'lib/initializers.rb'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/color'

class TestFormatter < Minitest::Test
  def test_format_grid
    assert_equal([
      ['a ', 'b ', 'c '],
      %w{de fg hi}
    ], Formatter.format_grid([
      %w{a b c},
      %w{de fg hi}
    ]))
  end

  def test_to_grid_s
    assert_equal([
        ['a ', 'b ', 'c '],
        %w{de fg hi}
      ].map do |row|
        row.join("\t")
      end.join("\n"),
      Formatter.to_grid_s([
        ['a ', 'b ', 'c '],
        %w{de fg hi}
      ])
    )
  end

  def test_column_label_to_index
    assert_equal(0, Formatter.column_label_to_index('A'))
    assert_equal(1, Formatter.column_label_to_index('B'))
    assert_equal(27, Formatter.column_label_to_index('AB'))
    assert_equal(52, Formatter.column_label_to_index('BA'))
  end

  def test_column_index_label
    assert_equal('A', Formatter.column_index_label(0))
    assert_equal('B', Formatter.column_index_label(1))
    assert_equal('AB', Formatter.column_index_label(27))
    assert_equal('BA', Formatter.column_index_label(52))
  end

  def test_next_column_index_label
    assert_equal('A', Formatter.next_column_index_label(''))
    assert_equal('B', Formatter.next_column_index_label('A'))
    assert_equal('AA', Formatter.next_column_index_label('Z'))
  end

  def test_with_axis_labels
    assert_equal([
      ['', 'A', 'B', 'C'],
      [0, 'foo', 'bar', 'bat']
    ], Formatter.with_axis_labels([
      %w{foo bar bat}
    ]))
  end
end
