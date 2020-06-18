require "nxt_support/preprocessors/strip_preprocessor"
require "nxt_support/preprocessors/downcase_preprocessor"

module NxtSupport
  class Preprocessor
    extend NxtRegistry

    PREPROCESSORS = registry :preprocessors, callable: false do
      nested :string do
        register :strip, NxtSupport::Preprocessors::StripPreprocessor
        register :downcase, NxtSupport::Preprocessors::DowncasePreprocessor
      end
    end

    attr_accessor :columns, :options

    def initialize(columns, options)
      @options = options
      @columns = valid_attributes(columns)
    end

    def process(record)
      columns.each do |column|
        preprocessors_keys = options[:preprocessors]

        value_to_process = record[column]
        processed_value = process_value(value_to_process, preprocessors_keys)
        record[column] = processed_value
      end
    end

    def type
      options[:column_type] || :string
    end

    private

    def valid_attributes(attributes)
      if options[:only]
        attributes.select! { |attr| attr.in?(options[:only]) }
      elsif options[:except]
        attributes.reject! { |attr| attr.in?(options[:except]) }
      end

      attributes
    end

    def process_value(value, preprocessor_keys)
      preprocessor_keys.each do |key|
        value = resolve(key, value)
      end

      value
    end

    def resolve(key, value)
      if key.respond_to?(:lambda?)
        key.call(value)
      else
        PREPROCESSORS.resolve(type).resolve(key).new(value).call
      end
    end

    class << self
      def register(name, preprocessor, type = :string)
        PREPROCESSORS.resolve!(type).register(name, preprocessor)
      end
    end
  end
end
