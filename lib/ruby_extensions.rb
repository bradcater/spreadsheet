require 'parallel'

class Array
  def left
    size < 2 ? self : self[0..(size/2).floor-1]
  end
  def right
    size < 2 ? [] : self[(size/2).floor..-1]
  end
  def mean
    empty? ? nil : sum / size.to_f
  end
  alias_method :average, :mean
  def product
    if empty?
      nil
    elsif size == 1
      first
    elsif size == 2
      first * last
    else
      Parallel.map([left, right]) do |side|
        side.product
      end.product
    end
  end
  def sum
    inject(0){|s, o| s + o}.to_f
  end
end

class NilClass
  def blank? ; true ; end
  def present? ; false ; end
  def try(*a, &b) ; nil ; end
end

class Object
  def blank? ; false ; end
  def present? ; true ; end

  # Taken from
  # activesupport/lib/active_support/core_ext/object/try.rb
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      public_send(*a, &b) if respond_to?(a.first)
    end
  end
end

class String
  def blank? ; strip == '' ; end
  def first ; self[0] ; end
  def last ; self[-1] ; end
  def pad_to_width(w, pad_char=' ')
    self + (pad_char * (w - self.size))
  end
end
