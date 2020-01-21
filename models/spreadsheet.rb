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
    # dgraph is the dependency graph of cells.
    @dgraph = Graph.new
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
    node = @dgraph.nodes.find{|n| n.name == [row, col]}
    @dgraph.remove_node(node) if node
  end

  def set_cell(row, col, value)
    value = value.strip if value.is_a?(String)
    if FormulaCell.formula?(value)
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
      puts "@dgraph before modification"
      @dgraph.nodes.each do |n|
        puts n
        n.edges.each do |e|
          puts "#{e.from_node} -> #{e.to_node}"
        end
      end
      node = @dgraph.nodes.find{|n| n.name == [row, col]}
      node_existed = !!node
      node ||= Node.new([row, col])
      @dgraph.add_node(node) unless node_existed
      # Only populate added_edges if node already existed in the graph. There's
      # no reason to populate it if rollback would entail removing the whole new
      # node that we added.
      added_edges = []
      cell_indices.each do |cell_index|
        tmp_node = @dgraph.nodes.find{|n| n.name == cell_index}
        tmp_node_existed = !!tmp_node
        tmp_node ||= Node.new(cell_index)
        @dgraph.add_node(tmp_node) unless tmp_node_existed
        e = Edge.new(node, tmp_node)
        node.add_edge(e)
        # If the node exists, then add an edge that can be removed if there's a
        # cycle.
        # Otherwise, create and add a node that can be removed if there's a
        # cycle.
        if node_existed
          added_edges << e
        end
      end
      if @dgraph.cyclic?
        raise "This introduces a cycle, so it can't be done."
        # If we add error handling code, then run this to rollback.
        #if node_existed
        #  added_edges.each do |e|
        #    node.remove_edge(e)
        #  end
        #else
        #  @dgraph.remove_node(node)
        #end
      end
      puts "@dgraph after modification"
      @dgraph.nodes.each do |n|
        puts n
        n.edges.each do |e|
          puts "#{e.from_node} -> #{e.to_node}"
        end
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
    else
      unless @dgraph.nodes.any?{|n| n.name == [row, col]}
        puts "adding #{[row, col]}"
        @dgraph.add_node(Node.new([row, col]))
      end
      if StaticCell.number?(value)
        @rows[row][col] = NumberCell.new(value)
      else
        @rows[row][col] = StringCell.new(value)
      end
    end
    update_dependencies!(row, col)
  end

  def update_dependencies!(row, col)
    get_raw_cell(row, col).update!
    @dgraph.nodes.each do |node|
      node.edges.each do |edge|
        if edge.to_node.name == [row, col]
          update_dependencies!(*edge.from_node.name)
          get_raw_cell(row, col).update!
        end
      end
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
    @dgraph.nodes.each do |node|
      if node.name[1] == col
        @dgraph.remove_node(node)
      end
    end
    @dgraph.nodes.each do |node|
      if node.name[1] > col
        node.rename!([node.name[0], node.name[1] - 1])
      end
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
    @dgraph.nodes.each do |node|
      if node.name[0] == row
        @dgraph.remove_node(node)
      end
    end
    @dgraph.nodes.each do |node|
      if node.name[0] > row
        node.rename!([node.name[0] - 1, node.name[1]])
      end
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
