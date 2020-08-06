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
    context 'when the values are unique' do
      it 'reveals the value' do

      end
    end

    context 'when the values are not unique' do
      it 'raises an error' do

      end
    end
  end
end
