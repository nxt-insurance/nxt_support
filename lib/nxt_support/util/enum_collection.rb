module NxtSupport
  class EnumCollection < ActiveSupport::HashWithIndifferentAccess
    def initialize(*keys)
      super()

      keys.each do |key|
        normalized_key = normalized_key(key)
        self[normalized_key] = NxtSupport::Enum.new(key.to_s)
        define_getter(normalized_key)
      end

      freeze
    end

    def self.[](*keys)
      new(*keys)
    end

    def [](key)
      super(key) || (raise KeyError, "No value for key '#{key}' in #{inspect}")
    end

    private

    def normalized_key(key)
      key.to_s.downcase.underscore.gsub(/\s+/, '_')
    end

    def define_getter(normalized_key)
      define_singleton_method normalized_key do
        fetch(normalized_key)
      end
    end
  end
end
