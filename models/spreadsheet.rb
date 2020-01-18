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

  def add_row
    @rows << [nil] * get_column_count
  end

  def add_column
    @rows.each do |row|
      row << nil
    end
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
      cell_indices = if value =~ /([A-Z]+\d+\:[A-Z]+\d+)/
        from, to = value.split(/:/)
        from = from.gsub(/^.+?\(/, '')
        to = to.gsub(/\)$/, '')
        from_row = from.gsub(/[A-Z]+/, '')
        from_col = from.gsub(/\d+/, '')
        to_row = to.gsub(/[A-Z]+/, '')
        to_col = to.gsub(/\d+/, '')
        unless from_row == to_row || from_col == to_col
          raise "Only single row and single column dependencies are supported."
        end
        tmp = if from_row == to_row
          if to_row.to_i < from_row.to_i
            from_row, to_row = [to_row, from_row]
          end
          (from_col..to_col).map do |col|
            "#{col}#{from_row}"
          end
        else
          (from_row.to_i..to_row.to_i).map do |row|
            "#{from_col}#{row}"
          end
        end
        tmp.map do |r|
          Formatter.direct_ref_to_coords(r)
        end
      else
        value.scan(/([A-Z]+\d+|\((\d+,\d+)\))/).map do |pair|
          # pair will be of the form
          # ["A0", nil]
          # or of the form
          # ["(0,0)", "0,0"]
          if pair.last.nil?
            letters = pair.first.match(/^([A-Z]+)/)[0]
            numbers = pair.first.match(/(\d+)$/)[0]
            [numbers.to_i, Formatter.column_label_to_index(letters)]
          else
            pair.last.split(/,/).map(&:to_i)
          end
        end
      end
      unless FormulaCell.valid_indices?(row, col, cell_indices)
        raise 'A FormulaCell cannot refer to itself.'
      end
      if [
        AbsCell,
        RefCell
      ].include?(klass = FormulaCell.formula_type(value))
        @rows[row][col] = klass.new(self, cell_indices.first)
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

  def can_remove_column?(col)
    return false if col < 0
    return false if col > get_column_count - 1
    return true if @rows.all?{|row| row[col].nil?}
    false
  end
  def can_remove_row?(row)
    return false if row < 0
    return false if row > get_row_count - 1
    return true if @rows[row].all?(&:nil?)
    false
  end
  def remove_column(col)
    unless can_remove_column?(col)
      raise "Cannot remove column #{col}."
    end
    @rows.map! do |row|
      col == 0 ? row[col+1..-1] : (row[0..col-1] + row[col+1..-1])
    end
    (col..get_column_count-1).each do |col_idx|
      (0..get_row_count-1).each do |row_idx|
        if (cell = get_raw_cell(row_idx, col_idx)).is_a?(FormulaCell)
          if cell.is_a?(SingleDependencyFormulaCell)
            cell.cell_index = [
              cell.cell_index.first,
              cell.cell_index.last >= col ? cell.cell_index.last - 1 : cell.cell_index.last
            ]
          elsif cell.is_a?(PairDependencyFormulaCell) ||
            cell.is_a?(MultiDependencyFormulaCell)
            cell.cell_indices.map! do |cell_index|
              [cell_index.first,
               cell_index.last >= col ? cell_index.last - 1 : cell_index.last]
            end
          else
            raise "Unknown cell type: #{cell}"
          end
        end
      end
    end
    @dependencies = @dependencies.inject({}) do |hsh, (depender, dependees)|
      if depender.last >= col
        depender = [depender.first, depender.last - 1]
      end
      new_dependees = Set.new
      dependees.to_a.each do |dependee|
        new_dependees << [
          dependee.first,
          dependee.last >= col ? dependee.last - 1 : dependee.last
        ]
      end
      hsh[depender] = new_dependees
      hsh
    end
  end
  def remove_row(row)
    unless can_remove_row?(row)
      raise "Cannot remove row #{row}."
    end
    @rows = row == 0 ? @rows[row+1..-1] : (@rows[0..row-1] + @rows[row+1..-1])
    (row..get_row_count-1).each do |row_idx|
      (0..get_column_count-1).each do |col_idx|
        if (cell = get_raw_cell(row_idx, col_idx)).is_a?(FormulaCell)
          if cell.is_a?(SingleDependencyFormulaCell)
            cell.cell_index = [
              cell.cell_index.first >= row ? cell.cell_index.first - 1 : cell.cell_index.first,
              cell.cell_index.last
            ]
          elsif cell.is_a?(PairDependencyFormulaCell) ||
            cell.is_a?(MultiDependencyFormulaCell)
            cell.cell_indices.map! do |cell_index|
              [cell_index.first >= row ? cell_index.first - 1 : cell_index.first,
               cell_index.last]
            end
          else
            raise "Unknown cell type: #{cell}"
          end
        end
      end
    end
    @dependencies = @dependencies.inject({}) do |hsh, (depender, dependees)|
      if depender.first >= row
        depender = [depender.first - 1, depender.last]
      end
      new_dependees = Set.new
      dependees.to_a.each do |dependee|
        new_dependees << [
          dependee.first >= row ? dependee.first - 1 : dependee.first,
          dependee.last
        ]
      end
      hsh[depender] = new_dependees
      hsh
    end
  end

  def to_s
    Formatter.to_grid_s(
      Formatter.format_grid(
        Formatter.with_axis_labels(@rows.map do |row|
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
