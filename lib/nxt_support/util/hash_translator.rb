module NxtSupport
  module HashTranslator
    class HashTranslationService
      class InvalidTranslationArgument < StandardError; end

      require 'nxt_init'

      include NxtInit
      attr_init :hash, :tuples

      def call
        tuples.inject(hash.with_indifferent_access) do |acc, (old_key, new_key)|
          if new_key.is_a?(Hash)
            raise InvalidTranslationArgument.new("#{new_key} hash must contain only 1 key-value pair!") if new_key.size > 1
            key, value = new_key.shift
            raise InvalidTranslationArgument.new("#{value} must be a callable block!") unless value.respond_to?(:call)
            acc[key] = value.call(acc.delete(old_key))
          elsif new_key.is_a?(Array)
            value = acc.delete(old_key)
            new_key.each { |key| acc[key] = value }
          else
            acc[new_key] = acc.delete(old_key)
          end

          acc
        end
      end
    end

    def translate_hash(hash, **tuples)
      HashTranslationService.new(hash: hash, tuples: tuples).call
    end
  end
end
