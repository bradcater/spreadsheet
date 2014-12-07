$:<< '.'

require 'set'

load 'lib/initializers.rb'

class Spreadsheet

  DEFAULT_ROWS = 5
  DEFAULT_COLUMNS = 5
  def initialize(opts={})
    if opts[:rows].try(:<, 1)
      raise "Invalid number of rows: #{opts[:rows]}"
    elsif opts[:columns].try(:<, 0)
      raise "Invalid number of columns: #{opts[:columns]}"
    end
    @rows = []
    (opts[:rows] || DEFAULT_ROWS).times do
      @rows << [nil] * (opts[:columns] || DEFAULT_COLUMNS)
    end
    # @dependencies is a map of (i,j) -> [(k,l),...] that depend on (i,j)
    @dependencies = {}
  end

  def get_row_count ; @rows.size ; end
  def get_column_count ; @rows.first.size ; end

  def get_raw_cell(row, col)
    @rows[row][col]
  end
  def get_cell(row, col)
    get_raw_cell(row, col).try(:get_value)
  end

  def clear_cell(row, col)
    @rows[row][col] = nil
    @dependencies.delete([row, col])
  end

  def set_cell(row, col, value)
    value = value.strip if value.is_a?(String)
    if FormulaCell.formula?(value)
      unless can_set_formula_cell?(row, col)
        raise "Cannot set FormulaCell for (#{row},#{col})."
      end
      cell_indices = value.scan(/\(\d+,\d+\)/).map do |pair|
        pair.gsub(/^\(/, '').gsub(/\)$/, '').split(/,/).map(&:to_i)
      end
      unless FormulaCell.valid_indices?(row, col, cell_indices)
        raise 'A FormulaCell cannot refer to itself.'
      end
      if (klass = FormulaCell.formula_type(value)) == AbsCell
        @rows[row][col] = AbsCell.new(self, cell_indices.first)
      elsif klass
        @rows[row][col] = klass.new(self, cell_indices)
      else
        raise 'NYI'
      end
      cell_indices.each do |cell_index|
        @dependencies[cell_index] ||= Set.new
        @dependencies[cell_index] << [row, col]
      end
    elsif StaticCell.number?(value)
      @rows[row][col] = NumberCell.new(value)
    else
      @rows[row][col] = StringCell.new(value)
    end
    update_dependencies!(row, col)
  end

  def can_set_formula_cell?(row, col, visited=Set.new)
    visited << [row, col]
    (@dependencies[[row, col]] || []).each do |cell_index|
      return false if visited.include?(cell_index)
      visited << cell_index
      return false unless can_set_formula_cell?(*[cell_index, visited].flatten)
    end
    true
  end

  def update_dependencies!(row, col)
    get_raw_cell(row, col).update!
    (@dependencies[[row, col]] || []).each do |cell_index|
      update_dependencies!(*cell_index)
      get_raw_cell(*cell_index).update!
    end
  end

  def to_s
    Formatter.to_grid_s(
      Formatter.with_axis_labels(
        Formatter.format_grid(@rows.map do |row|
          row.map do |cell|
            cell.try(:get_value) || 'nil'
          end
        end)
      )
    )
  end

  def to_class_s
    @rows.map do |row|
      row.map do |cell|
        cell.nil? ? 'nil' : cell.class.to_s
      end.join("\t")
    end.join("\n")
  end
end
