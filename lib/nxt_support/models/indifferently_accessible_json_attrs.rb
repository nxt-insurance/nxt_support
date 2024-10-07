module NxtSupport
  module IndifferentlyAccessibleJsonAttrs
    extend ActiveSupport::Concern

    class JsonSerializer
      class << self
        def load(str)
          indifferent_accessable(JSON.load(str))
        end

        def dump(obj)
          JSON.dump(obj)
        end

        private

        def indifferent_accessable(obj)
          if obj.is_a?(Array)
            obj.map! { |o| indifferent_accessable(o) }
          elsif obj.is_a?(Hash)
            obj.with_indifferent_access
          elsif obj.is_a?(NilClass)
            obj
          else
            raise ArgumentError, "Cant deserialize '#{obj}'"
          end
        end
      end
    end

    class_methods do
      def indifferently_accessible_json_attrs(*attrs)
        attrs.each do |attr|

          serialize attr, coder: JsonSerializer
          # serialize attr, JsonSerializer
        end
      end

      alias_method :indifferently_accessible_json_attr, :indifferently_accessible_json_attrs
    end
  end
end
