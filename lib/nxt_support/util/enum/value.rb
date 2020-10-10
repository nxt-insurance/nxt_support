module NxtSupport
  class Enum::Value < String
    def initialize(value)
      super(value.to_s).freeze
    end
  end
end
