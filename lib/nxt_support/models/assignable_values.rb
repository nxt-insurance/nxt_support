module NxtSupport
  module AssignableValues
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :assignable_values

      def assignable_values_for(column, **options, &values)
        @assignable_values ||= {}
        @assignable_values[column.to_sym] = {
          values: values.call,
          default: options[:default]
        }

        define_assignable_instance_methods
      end

      def assignable_values_list_for(column)
        assignable_values[column][:values]
      end

      def define_assignable_instance_methods
        assignable_values.keys.each do |key|
          define_method :"valid_#{key.to_s.pluralize}" do
            self.class.assignable_values_list_for(key)
          end
        end
      end
    end

    included do
      validate :values_are_assignable
      after_initialize :set_default_assignable

      private

      def values_are_assignable
        attributes_to_validate.each do |attr|
          next if changes_to_validate[attr].blank?
          next if changes_to_validate[attr].in?(self.class.assignable_values[attr][:values])

          errors.add(attr, "the value #{changes_to_validate[attr]} is not in the list of acceptable values")
        end
      end

      def set_default_assignable
        self.class.assignable_values.each do |column, assignable|
          next unless new_record? && send(column).nil?

          if assignable[:default]
            send("#{column}=", assignable[:default])
          end
        end
      end

      def changed_keys
        changes.keys.map(&:to_sym)
      end

      def attributes_to_validate
        new_record? ? self.class.assignable_values.keys : (changed_keys & self.class.assignable_values.keys)
      end

      def changes_to_validate
        new_record? ? attributes.symbolize_keys : changed_attributes.symbolize_keys
      end
    end
  end
end
