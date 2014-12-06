class AbsCell < FormulaCell
  def initialize(spreadsheet, cell_index)
    @spreadsheet = spreadsheet
    @cell_index = cell_index
    update!
  end
  def update!
    @value = @spreadsheet.get_cell(*@cell_index).try(:abs)
  end
end
