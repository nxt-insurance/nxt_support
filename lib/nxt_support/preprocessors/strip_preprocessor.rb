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
      rescue NoMethodError => e
        raise WrongTypeError, "Tried to call #{e.name} on #{value}, but #{value} does not respond to #{e.name}"
      end
    end
  end
end
