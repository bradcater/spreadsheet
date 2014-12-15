class SingleDependencyFormulaCell < FormulaCell
  attr_accessor :cell_index
  def initialize(spreadsheet, cell_index)
    @spreadsheet = spreadsheet
    @cell_index = cell_index
    update!
  end
end
