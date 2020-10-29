module NxtSupport
  module Services
    module Base
      module ClassMethods
        def class_interface(config = :call)
          if config.is_a?(Hash)
            define_singleton_method config.values.first do |*args, **opts|
              build_instance(*args, **opts).send(config.values.first)
            end
          elsif config.is_a?(Symbol)
            define_singleton_method config do |*args, **opts|
              build_instance(*args, **opts).send(config)
            end
          else
            raise ArgumentError, "Wrong configuration. Please use 'class_interface call: :your_method_name'"
          end
        end

        private

        # Ruby <2.7-specific check. If the gem is updated to 2.7, `**opts` will work.
        def build_instance(*args, **opts)
          if opts.empty?
            new(*args, **{})
          else
            new(*args, **opts)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.class_interface
      end
    end
  end
end
