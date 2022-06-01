module NxtSupport
  class Crystalizer
    Error = Class.new(StandardError)

    include NxtInit

    attr_init :collection, on_ambiguity: -> { default_ambiguity_handler }, with: :itself

    def call
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

      on_ambiguity.arity == 1 ? on_ambiguity.call(resolved_collection) : on_ambiguity.call
    end
  end
end
