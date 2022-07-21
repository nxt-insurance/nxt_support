module NxtSupport
  class Enum
    def initialize(*keys)
      @store = ActiveSupport::HashWithIndifferentAccess.new

      keys.each do |key|
        normalized_key = normalized_key(key)
        store[normalized_key] = NxtSupport::Enum::Value.new(key)
        define_getter(normalized_key)
      end

      freeze
    end

    def self.[](*keys)
      new(*keys)
    end

    def [](key)
      store[key] || (raise KeyError, "No value for key '#{key}' in #{store}")
    end

    def to_h
      store
    end

    def strings
      values
    end

    def symbols
      values.map(&:to_sym)
    end

    delegate_missing_to :to_h

    private

    attr_reader :store

    def normalized_key(key)
      key.to_s.downcase.underscore.gsub(/\s+/, '_')
    end

    def define_getter(normalized_key)
      define_singleton_method normalized_key do
        store[normalized_key]
      end
    end
  end
end
