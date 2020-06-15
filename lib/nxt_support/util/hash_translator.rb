module NxtSupport
  module HashTranslator
    extend ActiveSupport::Concern

    class HashTranslationService
      require 'nxt_init'

      include NxtInit
      attr_init :hash, :tuples

      def call
        tuples.inject(hash.with_indifferent_access) do |acc, (old_key, new_key)|
          if new_key.is_a?(Hash)
            key = new_key.keys.first
            value = new_key.values.last
            value = value.respond_to?(:call) ? value.call(acc.delete(old_key)) : value
            acc[key] = value
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

    class_methods do
      def translate_hash(hash, **tuples)
        HashTranslationService.new(hash: hash, tuples: tuples).call
      end
    end
  end
end
