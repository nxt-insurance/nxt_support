module NxtSupport
  module Models
    module SafelyFindOrCreateable
      extend ActiveSupport::Concern

      module ClassMethods
        def safely_find_or_create_by(attributes, &block)
          transaction(requires_new: true) { create(attributes, &block) }
        rescue ActiveRecord::RecordNotUnique
          find_by(attributes)
        end

        def safely_find_or_create_by!(attributes, &block)
          transaction(requires_new: true) { create!(attributes, &block) }
        rescue ActiveRecord::RecordNotUnique
          find_by!(attributes)
        rescue ActiveRecord::RecordInvalid => e
          all_errors_are_uniqueness_failures = e.record.errors.details.all? { |_key, errs| errs.all? { |err| err[:error] == :taken } }
          raise unless all_errors_are_uniqueness_failures
          find_by!(attributes)
        end
      end
    end
  end
end
