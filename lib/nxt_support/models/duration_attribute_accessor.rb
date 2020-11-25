module NxtSupport
  module DurationAttributeAccessor
    extend ActiveSupport::Concern

    class_methods do
      def duration_attribute_accessor(*attrs)
        duration_attribute_reader(*attrs)
        duration_attribute_writer(*attrs)
      end

      def duration_attribute_reader(*attrs)
        attrs.each do |attr_name|
          define_duration_attribute_reader(attr_name)
        end
      end

      def duration_attribute_writer(*attrs)
        attrs.each do |attr_name|
          define_duration_attribute_writer(attr_name)
        end
      end

      private

      def define_duration_attribute_reader(attr_name)
        define_method(attr_name) do
          duration_string = read_attribute(attr_name)
          return if duration_string.nil?

          ActiveSupport::Duration.parse(duration_string)
        end
      end

      def define_duration_attribute_writer(attr_name)
        define_method("#{attr_name}=") do |value|
          case value
          when ActiveSupport::Duration
            write_attribute(attr_name, value.iso8601)
          when String
            if is_valid_iso8601_duration?(value)
              write_attribute(attr_name, value)
            else
              raise ArgumentError, "'#{value}' is not a valid iso8601 string"
            end
          when NilClass
            write_attribute(attr_name, value)
          else
            raise ArgumentError, 'Please provide an ActiveSupport::Duration object or an iso8601 formatted string'
          end
        end
      end
    end


    def is_valid_iso8601_duration?(string)
      ActiveSupport::Duration.parse(string)
      true
    rescue ActiveSupport::Duration::ISO8601Parser::ParsingError
      false
    end
  end
end
