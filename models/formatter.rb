class Formatter
  def self.format_grid(grid)
    # Map col_idx -> maximum column width
    max_widths = {}
    grid.each do |row|
      row.each.with_index do |cell, col_idx|
        cell_s = cell.is_a?(String) ? cell : cell.to_s
        max_widths[col_idx] ||= cell_s.size
        max_widths[col_idx] = cell_s.size if cell_s.size > max_widths[col_idx]
      end
    end
    grid.map do |row|
      row.map.with_index do |cell, col_idx|
        cell.to_s.pad_to_width(max_widths[col_idx])
      end
    end
  end

  def self.to_grid_s(grid, opts={})
    opts[:col_sep] ||= "\t"
    opts[:row_sep] ||= "\n"
    grid.map do |row|
      row.join(opts[:col_sep])
    end.join(opts[:row_sep])
  end

  def self.column_label_to_index(column_label)
    (column_label.split('').map.with_index do |c, idx|
       (c.ord - 65 + 1) * (26 ** (column_label.size - idx - 1))
     end.sum - 1).to_i
  end

  def self.next_column_index_label(current_column_index_label)
    if current_column_index_label.blank?
      column_index_label(0)
    else
      column_index_label(column_label_to_index(current_column_index_label) + 1)
    end
  end
  def self.column_index_label(index)
    # 'A'.ord -> 65
    # 'Z'.ord -> 90
    q = index / 26
    if q > 0
      column_index_label(q - 1) + ((index % 26) + 65).chr
    else
      ((index % 26) + 65).chr
    end
  end

  def self.with_axis_labels(grid)
    return grid if grid.empty? || grid.first.empty?
    rows = []
    header_row = ['']
    grid.first.size.times do
      header_row << next_column_index_label(header_row.last)
    end
    rows << header_row
    grid.each.with_index do |row, row_idx|
      rows << ([row_idx] + row)
    end
    rows
  end
end
