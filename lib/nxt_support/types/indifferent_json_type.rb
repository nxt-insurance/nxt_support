require 'active_record'

module NxtSupport
  class IndifferentJsonType < ActiveRecord::Type::Json
    def deserialize(value)
      indifferent(decode_legacy_double_encoding(super))
    end

    def cast(value)
      indifferent(value)
    end

    private

    def decode_legacy_double_encoding(value)
      return value unless value.is_a?(::String) && value.start_with?('{', '[')

      ActiveSupport::JSON.decode(value)
    rescue JSON::ParserError
      value
    end

    def indifferent(value)
      case value
      when Hash then value.with_indifferent_access
      when Array then value.map { |element| indifferent(element) }
      when nil then nil
      else raise ArgumentError, "Cant deserialize '#{value}'"
      end
    end
  end
end
