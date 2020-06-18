module NxtSupport
  module Preprocessors
    class WrongTypeError < StandardError; end
    class DowncasePreprocessor
      attr_accessor :value

      def initialize(value)
        @value = value
      end

      def call
        return if value.nil?

        value.downcase!
        value
      rescue NoMethodError
        raise WrongTypeError, 'Attribute type is not supported for this preprocessor'
      end
    end
  end
end
