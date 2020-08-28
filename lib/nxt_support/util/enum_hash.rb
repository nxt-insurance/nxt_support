module NxtSupport
  class EnumHash < ActiveSupport::HashWithIndifferentAccess
    def initialize(*keys)
      super()

      keys.each do |key|
        self[normalized_key(key)] = NxtSupport::Enum.new(key.to_s)
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
  end
end
