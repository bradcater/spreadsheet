class RefCell < SingleDependencyFormulaCell
  def update!
    @value = @spreadsheet.get_cell(*@cell_index)
  end
end
