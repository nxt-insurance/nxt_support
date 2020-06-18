module NxtSupport
  module Preprocessors
    class DowncasePreprocessor
      attr_accessor :value

      def initialize(value)
        @value = value
      end

      def call
        return value unless value.is_a?(String)

        value.downcase!
        value
      end
    end
  end
end
