module NxtSupport
  module AssignableValues
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :assignable_values

      def assignable_values_for(column, values = [], **options, &block)
        @assignable_values ||= {}
        @assignable_values[column.to_sym] = {
          values: (block_given? ? block.call : values),
          default: options[:default],
          allow_blank: options[:allow_blank]
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
    end

    private

    def values_are_assignable
      attributes_to_validate.each do |attr|
        next if changes_to_validate[attr].blank? && allow_blank_for?(attr)
        next if changes_to_validate[attr].in?(assignable_values_for(attr))

        if changes_to_validate[attr].blank?
          errors.add(attr, "can't be blank.")
        else
          errors.add(attr, "the value #{changes_to_validate[attr]} is not in the list of acceptable values.")
        end
      end
    end

    def set_default_assignable
      self.class.assignable_values.each do |column, assignable|
        next unless new_record? && send(column).nil? && assignable[:default]

        if assignable[:default].is_a? Proc
          send("#{column}=", instance_exec(&assignable[:default]))
        else
          send("#{column}=", assignable[:default])
        end
      end
    end

    def allow_blank_for?(attr)
      self.class.assignable_values[attr][:allow_blank]
    end

    def assignable_values_for(attr)
      self.class.assignable_values[attr][:values]
    end

    def attributes_to_validate
      new_record? ? self.class.assignable_values.keys : (changed_keys & self.class.assignable_values.keys)
    end

    def changed_keys
      changes.keys.map(&:to_sym)
    end

    def changes_to_validate
      new_record? ? attributes.symbolize_keys : changes.transform_values(&:last).symbolize_keys
    end
  end
end
