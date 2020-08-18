module NxtSupport
  class Crystallizer
    Error = Class.new(StandardError)

    include NxtInit

    attr_init :collection, on_uniqueness_violation: -> { uniqueness_violation_handler }, attribute: :itself

    def call
      ensure_values_are_unique
      unique_values.first
    end

    private

    def unique_values
      @unique_values ||= resolved_collection.uniq
    end

    def resolved_collection
      @resolved_collection ||= collection.map { |value| value.send(attribute) }
    end

    def uniqueness_violation_handler
      ->(collection) { raise Error, "Values in collection are not unique: #{collection}" }
    end

    def ensure_values_are_unique
      return if unique_values.size == 1

      on_uniqueness_violation.call(collection)
    end
  end
end
