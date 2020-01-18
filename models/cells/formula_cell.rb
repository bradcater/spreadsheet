class FormulaCell < Cell
  def update!
    raise 'NYI'
  end
  def self.formula?(o)
    o.is_a?(String) && o =~ /^=/
  end
  def self.formula_type(o)
    if o =~ /^=ABS/
      AbsCell
    elsif o =~ /^=(AVG|MEAN)/
      AvgCell
    elsif o =~ /^=CONCAT/
      ConcatCell
    elsif o =~ /^=DIV/
      DivCell
    elsif o =~ /^=EXP/
      ExpCell
    elsif o =~ /^=MAX/
      MaxCell
    elsif o =~ /^=MEDIAN/
      MedianCell
    elsif o =~ /^=MIN/
      MinCell
    elsif o =~ /^=PROD/
      ProdCell
    elsif o=~ /^=REF/
      RefCell
    elsif o =~ /^=SUB/
      SubCell
    elsif o =~ /^=SUM/
      SumCell
    else
      nil
    end
  end
  def self.valid_indices?(row, col, cell_indices)
    !cell_indices.include?([row, col])
  end
end
