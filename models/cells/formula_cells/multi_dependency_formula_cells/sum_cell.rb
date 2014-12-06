require 'ryeppp'

class SumCell < MultiDependencyFormulaCell
  def update!
    @value = Ryeppp.sum_v64f_s64f(@cell_indices.map do |cell_index|
      @spreadsheet.get_cell(*cell_index)
    end.compact)
  end
end
