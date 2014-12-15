class SubCell < PairDependencyFormulaCell
  def update!
    @value = @cell_indices.map do |cell_index|
      @spreadsheet.get_cell(*cell_index)
    end
    @value = if @value.first.present? && @value.last.present?
      @value.first - @value.last
    elsif @value.first.present?
      @value.first
    else
      -1 * @value.last
    end
  end
end
