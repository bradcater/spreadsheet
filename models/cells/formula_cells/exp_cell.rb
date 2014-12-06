class ExpCell < FormulaCell
  def initialize(spreadsheet, cell_indices)
    @spreadsheet = spreadsheet
    @cell_indices = cell_indices
    if @cell_indices.size != 2
      raise "Invalid size for ExpCell cell_indices: #{@cell_indices.size}"
    end
    update!
  end
  def update!
    @value = @cell_indices.map do |cell_index|
      @spreadsheet.get_cell(*cell_index)
    end
    @value = if @value.first.present? && @value.last.present?
      @value.first ** @value.last
    else
      raise "Invalid arguments for ExpCell: #{@value.first}, #{@value.last}"
    end
  end
end
