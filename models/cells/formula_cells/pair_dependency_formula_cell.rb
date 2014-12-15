class PairDependencyFormulaCell < FormulaCell
  def initialize(spreadsheet, cell_indices)
    @spreadsheet = spreadsheet
    @cell_indices = cell_indices
    if @cell_indices.size != 2
      raise "Invalid size for #{self.class.to_s} cell_indices: #{@cell_indices.size}"
    end
    update!
  end
  def cell_indices
    @cell_indices
  end
end
