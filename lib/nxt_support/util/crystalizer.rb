module NxtSupport
  class Crystalizer
    Error = Class.new(StandardError)

    include NxtInit

    attr_init :collection, on_ambiguity: -> { default_ambiguity_handler }, with: :itself

    def call
      ensure_collection
      ensure_unanimity
      unique_values.first
    end

    private

    def unique_values
      @unique_values ||= resolved_collection.uniq
    end

    def resolved_collection
      @resolved_collection ||= collection.map { |value| with.is_a?(Proc) ? with.call(value) : value.send(with) }
    end

    def default_ambiguity_handler
      ->(collection) { raise Error, "Values in collection are not unanimous: #{collection}" }
    end

    def ensure_unanimity
      return if unique_values.size == 1

      on_ambiguity.arity == 1 ? on_ambiguity.call(collection) : on_ambiguity.call
    end

    def ensure_collection
      return if collection.respond_to?(:uniq)

      raise Error, "Cannot determine unique values in: #{collection}! Maybe it's not a collection?"
    end
  end
end
