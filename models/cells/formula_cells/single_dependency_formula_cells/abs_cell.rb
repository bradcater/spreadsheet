class AbsCell < SingleDependencyFormulaCell
  def update!
    @value = @spreadsheet.get_cell(*@cell_index).try(:abs)
  end
end
