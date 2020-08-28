module NxtSupport
  class Enum < String
    def eql?(other)
      to_s == other.to_s
    end
  end
end
