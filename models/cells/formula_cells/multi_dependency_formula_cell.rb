class MultiDependencyFormulaCell < FormulaCell
  def initialize(spreadsheet, cell_indices)
    @spreadsheet = spreadsheet
    @cell_indices = cell_indices
    update!
  end
  def cell_indices
    @cell_indices
  end
end
