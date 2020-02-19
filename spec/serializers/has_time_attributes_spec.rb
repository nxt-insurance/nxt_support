RSpec.describe NxtSupport::HasTimeAttributes do
  subject do
    Class.new do
      include NxtSupport::HasTimeAttributes

      def object
        OpenStruct.new(
          date: Date.current,
          time: Time.current,
          duration: 1.year
        )
      end

      def self.attribute(attr_name)
      end
    end
  end

  let(:now) { Time.current }

  around(:each) do |example|
    travel_to(now) { example.run }
  end

  describe '#attributes_as_iso8601' do
    it 'defines accessor methods returning the object values as iso8601 string' do
      subject.attributes_as_iso8601 :date, :time, :duration
      serializer = subject.new

      expect(serializer).to respond_to(:date)
      expect(serializer).to respond_to(:time)
      expect(serializer).to respond_to(:duration)

      expect(serializer.date).to eq now.to_date.iso8601
      expect(serializer.time).to eq now.iso8601
      expect(serializer.duration).to eq 1.year.iso8601
    end

    it 'calls the attribute method of the serializer interface' do
      expect(subject).to receive(:attribute).with(:date)
      expect(subject).to receive(:attribute).with(:time)
      expect(subject).to receive(:attribute).with(:duration)

      subject.attributes_as_iso8601 :date, :time, :duration
    end
  end

  describe '#attribute_as_iso8601' do
    it 'defines accessor methods returning the object values as iso8601 string' do
      subject.attribute_as_iso8601 :date
      subject.attribute_as_iso8601 :time
      subject.attribute_as_iso8601 :duration
      serializer = subject.new

      expect(serializer).to respond_to(:date)
      expect(serializer).to respond_to(:time)
      expect(serializer).to respond_to(:duration)

      expect(serializer.date).to eq now.to_date.iso8601
      expect(serializer.time).to eq now.iso8601
      expect(serializer.duration).to eq 1.year.iso8601
    end

    it 'calls the attribute method of the serializer interface' do
      expect(subject).to receive(:attribute).with(:date)

      subject.attribute_as_iso8601 :date
    end
  end
end
