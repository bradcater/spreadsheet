class StaticCell < Cell
  def update! ; nil ; end
  def self.number?(o)
    return true if o.is_a?(Integer)
    (o =~ /^[-\.\d]+$/).present?
  end
  def self.string?(o)
    !number?(o)
  end
end
