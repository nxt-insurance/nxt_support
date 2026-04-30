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

      it 'stores the nil value' do
        expect(course.attributes['class_duration']).to eq(nil)
      end

      it 'returns nil value' do
        expect(course.class_duration).to eq(nil)
      end
    end

    context 'when given attribute is a non-ISO8601 string' do
      let(:course) do
        subject.new(class_duration: '1 month')
      end

      it 'raises an ArgumentError' do
        expect { course }.to raise_error(ArgumentError).with_message(/is not a valid iso8601 string/)
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

  describe '.validates_durations' do
    subject(:klass) do
      Class.new do
        include ActiveModel::Model
        include NxtSupport::DurationAttributeAccessor

        attr_accessor :class_duration, :topic_duration

        validates_durations :class_duration
      end
    end

    context 'when the value is a valid ISO8601 duration string' do
      it 'does not add an error' do
        record = klass.new(class_duration: 'PT1H')
        expect(record).to be_valid
      end
    end

    context 'when the value is an invalid string' do
      it 'adds an error with the invalid value in the message' do
        record = klass.new(class_duration: 'not_a_duration')
        expect(record).not_to be_valid
        expect(record.errors[:class_duration]).to include('is not a valid iso8601 duration.')
      end
    end

    context 'with allow_nil: true' do
      subject(:klass) do
        Class.new do
          include ActiveModel::Model
          include NxtSupport::DurationAttributeAccessor

          attr_accessor :class_duration

          validates_durations :class_duration, allow_nil: true
        end
      end

      it 'does not add an error for nil' do
        record = klass.new(class_duration: nil)
        expect(record).to be_valid
      end

      it 'still adds an error for an invalid string' do
        record = klass.new(class_duration: 'not_a_duration')
        expect(record).not_to be_valid
      end
    end

    context 'with multiple attributes' do
      subject(:klass) do
        Class.new do
          include ActiveModel::Model
          include NxtSupport::DurationAttributeAccessor

          attr_accessor :class_duration, :topic_duration

          validates_durations :class_duration, :topic_duration
        end
      end

      it 'validates all specified attributes' do
        record = klass.new(class_duration: 'not_valid', topic_duration: 'also_not_valid')
        expect(record).not_to be_valid
        expect(record.errors[:class_duration]).to be_present
        expect(record.errors[:topic_duration]).to be_present
      end
    end
  end
end
