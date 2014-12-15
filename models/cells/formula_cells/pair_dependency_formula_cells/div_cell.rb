class DivCell < PairDependencyFormulaCell
  def update!
    @value = @cell_indices.map do |cell_index|
      @spreadsheet.get_cell(*cell_index)
    end
    @value = if @value.first.present? && @value.last.present?
      @value.first / @value.last
    else
      raise "Invalid arguments for DivCell: #{@value.first}, #{@value.last}"
    end
  end
end
