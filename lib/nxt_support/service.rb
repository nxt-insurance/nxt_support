module NxtSupport
  module Service
    module ClassMethods
      def class_interface(config = :call)
        if config.is_a?(Hash)
          define_singleton_method config.keys.first do |*args, **opts, &block|
            new(*args, **opts, &block).send(config.values.first)
          end
        elsif config.is_a?(Symbol)
          define_singleton_method config do |*args, **opts, &block|
            new(*args, **opts, &block).send(config)
          end
        else
          raise ArgumentError, "Must either provide ..."
        end
      end
    end

    def self.included(base)
      base.include(NxtInit)
      base.extend(ClassMethods)
      base.class_interface
    end
  end
end
