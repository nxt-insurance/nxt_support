module NxtSupport
  module Services
    module ClassMethods
      def class_interface(config = :call)
        if config.is_a?(Hash)
          define_singleton_method config.values.first do |*args, **opts, &block|
            new_instance_with_or_without_args(*args, **opts, &block).send(config.values.first)
          end
        elsif config.is_a?(Symbol)
          define_singleton_method config do |*args, **opts, &block|
            new_instance_with_or_without_args(*args, **opts, &block).send(config)
          end
        else
          raise ArgumentError, "Wrong configuration. Please use 'class_interface call: :your_method_name'"
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.class_interface
      end

      private

      # Ruby <2.7-specific check. If the gem is updated to 2.7, `**opts` will work.
      def new_instance_with_or_without_args(*args, **opts, &block)
        if opts.empty?
          new(*args, **{}, &block)
        else
          new(*args, **opts, &block)
        end
      end
    end
  end
end
