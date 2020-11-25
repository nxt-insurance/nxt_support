RSpec.describe NxtSupport::DurationAttributeAccessor do
  let!(:db_schema) do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :courses, force: true do |t|
        t.string :class_duration
        t.string :topic_duration
        t.string :total_duration
      end
    end
  end

  describe 'A class with assignable_values' do
    subject do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'courses'
        include NxtSupport::DurationAttributeAccessor

        duration_attribute_accessor :class_duration, :topic_duration, :total_duration
      end
    end

    context 'when attributes have ActiveSupport::Duration type' do
      let(:course) do
        subject.new(
          class_duration: 1.hour,
          topic_duration: 1.month,
          total_duration: 1.year
        )
      end

      it 'stores values as ISO8601 strings' do
        expect(course.attributes['class_duration']).to eq('PT1H')
        expect(course.attributes['topic_duration']).to eq('P1M')
        expect(course.attributes['total_duration']).to eq('P1Y')
      end

      it 'returns ActiveSupport::Duration values if the accessors are used directly' do
        expect(course.class_duration).to eq(1.hour)
        expect(course.topic_duration).to eq(1.month)
        expect(course.total_duration).to eq(1.year)
      end
    end

    context 'when given attributes are ISO8601 strings' do
      let(:course) do
        subject.new(
          class_duration: 1.hour.iso8601,
          topic_duration: 1.month.iso8601,
          total_duration: 1.year.iso8601
        )
      end

      it 'stores values as ISO8601 strings' do
        expect(course.attributes['class_duration']).to eq('PT1H')
        expect(course.attributes['topic_duration']).to eq('P1M')
        expect(course.attributes['total_duration']).to eq('P1Y')
      end

      it 'returns ActiveSupport::Duration values if the accessors are used directly' do
        expect(course.class_duration).to eq(1.hour)
        expect(course.topic_duration).to eq(1.month)
        expect(course.total_duration).to eq(1.year)
      end
    end

    context 'when given attribute is nil' do
      let(:course) do
        subject.new(class_duration: nil)
      end

      it 'stores values as ISO8601 strings' do
        expect(course.attributes['class_duration']).to eq(nil)
      end

      it 'returns ActiveSupport::Duration values if the accessors are used directly' do
        expect(course.class_duration).to eq(nil)
      end
    end

    context 'when given attribute is a non-ISO8601 string' do
      let(:course) do
        subject.new(class_duration: '1 month')
      end

      it 'raises an ArgumentError' do
        expect { course }.to raise_error(ArgumentError).with_message(/'1 month' is not a valid iso8601 string/)
      end
    end

    context 'when given attribute is of an unsupported type' do
      let(:course) do
        subject.new(class_duration: 123)
      end

      it 'raises an ArgumentError' do
        expect { course }
          .to raise_error(ArgumentError)
          .with_message(/Please provide an ActiveSupport::Duration object or an iso8601 formatted string/)
      end
    end
  end
end
