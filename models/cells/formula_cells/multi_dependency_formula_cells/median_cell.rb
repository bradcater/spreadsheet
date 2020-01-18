require 'ryeppp'

class MedianCell < MultiDependencyFormulaCell
  def update!
    @value = @cell_indices.map do |cell_index|
      @spreadsheet.get_cell(*cell_index)
    end.compact.median
  end
end
