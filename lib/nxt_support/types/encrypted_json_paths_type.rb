require 'jsonpath'

module NxtSupport
  class EncryptedJsonPathsType < IndifferentJsonType
    attr_reader :paths, :scheme

    def self.normalize_path(path)
      path = path.to_s
      path.start_with?('$') ? path : "$.#{path}"
    end

    def initialize(*paths, deterministic: false)
      @paths = paths.map { |path| self.class.normalize_path(path) }
      @scheme = ActiveRecord::Encryption::Scheme.new(deterministic: deterministic)
      super()
    end

    def deserialize(value)
      map_leaves(super) { |leaf| decrypt(leaf) }
    end

    def serialize(value)
      super(map_leaves(indifferent(value)) { |leaf| encrypt(leaf) })
    end

    def encrypt_for_query(value)
      raise ArgumentError, 'querying encrypted fields requires deterministic: true' unless scheme.deterministic?

      encrypt(value)
    end

    private

    def map_leaves(object, &block)
      return object unless object.is_a?(Hash) || object.is_a?(Array)

      paths.reduce(object) { |result, path| JsonPath.for(result).gsub(path, &block).to_hash }
    end

    def encrypt(value)
      return value unless value.is_a?(::String)
      return value if encrypted?(value)

      encryptor.encrypt(value, key_provider: scheme.key_provider, cipher_options: { deterministic: scheme.deterministic? })
    end

    def decrypt(value)
      return value unless encrypted?(value)

      encryptor.decrypt(value, key_provider: scheme.key_provider)
    end

    def encrypted?(value)
      value.is_a?(::String) && encryptor.encrypted?(value)
    end

    def encryptor
      ActiveRecord::Encryption.encryptor
    end
  end
end
