module NxtSupport
  module Preprocessors
    class WrongTypeError < StandardError; end
    class StripPreprocessor
      attr_accessor :value

      def initialize(value)
        @value = value
      end

      def call
        return if value.nil?

        value.strip!
        value
      rescue NoMethodError
        raise WrongTypeError, 'Column type is not supported for this preprocessor'
      end
    end
  end
end
