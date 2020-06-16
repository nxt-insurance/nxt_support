module NxtSupport
  module PreprocessAttributes
    extend ActiveSupport::Concern
    VALID_PREPROCESSORS = %i[strip downcase]

    class Preprocessor
      class << self
        def process(value, preprocessors)
          preprocessors.each do |processor|
            send(processor, value)
          end

          value
        end

        def strip(value)
          value.strip! if value.respond_to?(:strip!)
          value
        end

        def downcase(value)
          value.downcase! if value.respond_to?(:downcase!)
          value
        end
      end
    end

    class_methods do
      attr_reader :nxt_preprocessors

      def preprocess_attributes(*columns, **options)
        @nxt_preprocessors ||= {}

        columns.each do |column|
          preprocessors = options[:preprocessors] || %i[strip]
          @nxt_preprocessors[column] = valid_preprocessors(preprocessors)
        end
      end

      def valid_preprocessors(preprocessors)
        preprocessors.select! { |preprocessor| preprocessor.in?(VALID_PREPROCESSORS) }
        preprocessors.map(&:to_sym)
      end
    end

    included do
      before_validation :preprocess_attributes
    end

    private

    def preprocess_attributes
      nxt_preprocessors.each do |column, preprocessors|
        value_to_process = send(column)
        processed_value = Preprocessor.process(value_to_process, preprocessors)

        send("#{column}=", processed_value)
      end
    end

    def nxt_preprocessors
      self.class.nxt_preprocessors
    end
  end
end
