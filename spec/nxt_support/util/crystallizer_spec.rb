RSpec.describe NxtSupport::Crystallizer do
  context 'without attribute' do
    subject do
      described_class.new(collection: collection).call
    end

    context 'when the values are unique' do
      let(:collection) { %w[andy andy andy] }

      it 'reveals the value' do
        expect(subject).to eq('andy')
      end
    end

    context 'when the values are not unique' do
      let(:collection) { %w[andy scotty] }

      it 'raises an error' do
        expect { subject }.to raise_error(NxtSupport::Crystallizer::Error, 'Values in collection are not unique: ["andy", "scotty"]')
      end
    end
  end

  context 'with attribute' do
    subject do
      described_class.new(collection: collection, attribute: :name).call
    end

    context 'when the values are unique' do
      let(:collection) { %w[andy andy andy].map { |name| OpenStruct.new(name: name) } }

      it 'reveals the value' do
        expect(subject).to eq('andy')
      end
    end

    context 'when the values are not unique' do
      let(:collection) { %w[andy scotty].map { |name| OpenStruct.new(name: name) } }

      it 'raises an error' do
        expect { subject }.to raise_error(NxtSupport::Crystallizer::Error, /Values in collection are not unique:/)
      end
    end
  end
end
