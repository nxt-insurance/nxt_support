module NxtSupport
  module Preprocessors
    class StripPreprocessor
      attr_accessor :value

      def initialize(value)
        @value = value
      end

      def call
        return value unless value.is_a?(String)

        value.strip!
        value
      end
    end
  end
end
