class Chronos::TimeInfinity < DateTime::Infinity
  def <=>(other)
    super other.to_i
  rescue
    super
  end

  def to_i
    to_f
  end

  def eql?(other)
    to_f.eql? other.to_f
  end

  def +(other)
    case other
      when TimeInfinity
        return TimeInfinity.new(d + other.d)
      when Date, DateTime, Time
        return 0
      when Numeric
        return self
    end
  end

  def -(other)
    case other
      when TimeInfinity
        return TimeInfinity.new(d - other.d)
      when Numeric
        return self
      when Date, DateTime, Time
        return 0
    end
  end

  def coerce(other)
    case other
      when Numeric
        return self, self
      when Date, DateTime, Time
        return other, to_f
      else
        super
    end
  end
end