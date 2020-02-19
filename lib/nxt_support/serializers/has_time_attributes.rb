module NxtSupport
  module HasTimeAttributes
    extend ActiveSupport::Concern

    module ClassMethods
      def attributes_as_iso8601(*attr_names)
        attr_names.each do |attr_name|
          attribute_as_iso8601(attr_name)
        end
      end

      def attribute_as_iso8601(attr_name)
        define_method(attr_name) do
          object.send(attr_name)&.iso8601
        end

        attribute attr_name
      end
    end
  end
end
