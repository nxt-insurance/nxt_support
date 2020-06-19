module NxtSupport
  module PreprocessAttributes
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :nxt_preprocessors

      def preprocess_attributes(*attributes, **options)
        attributes_to_process =
          if attributes.any?
            attributes.map(&:to_sym)
          else
            column_names.map(&:to_sym)
          end

        @nxt_preprocessors ||= []
        @nxt_preprocessors << NxtSupport::Preprocessor.new(attributes_to_process, options)
      end
    end

    included do
      before_validation do |record|
        nxt_preprocessors.each do |preprocessor|
          preprocessor.process(record)
        end
      end
    end

    private

    def nxt_preprocessors
      self.class.nxt_preprocessors
    end
  end
end
