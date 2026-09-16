RSpec.describe NxtSupport::Iban do
  describe '#normalize' do
    subject { described_class.new(iban: iban).normalize }

    context 'when the IBAN contains whitespace' do
      let(:iban) { 'DE89 3704 0044 0532 0130 00' }

      it { is_expected.to eq('DE89370400440532013000') }
    end

    context 'when the IBAN is written with lower-case letters' do
      let(:iban) { 'de89370400440532013000' }

      it { is_expected.to eq('DE89370400440532013000') }
    end

    context 'when the IBAN is written with lower-case letters and whitespace' do
      let(:iban) { ' de89 3704 0044 0532 0130 00 ' }

      it { is_expected.to eq('DE89370400440532013000') }
    end

    context 'when the IBAN contains tabs and newlines' do
      let(:iban) { "DE89\t3704\n0044 0532 0130 00" }

      it { is_expected.to eq('DE89370400440532013000') }
    end

    context 'when the IBAN is already normalized' do
      let(:iban) { 'DE89370400440532013000' }

      it { is_expected.to eq('DE89370400440532013000') }
    end

    context 'when the IBAN is an empty string' do
      let(:iban) { '' }

      it { is_expected.to eq('') }
    end

    context 'when the IBAN is nil' do
      let(:iban) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the IBAN is not a string' do
      let(:iban) { 42 }

      it { is_expected.to eq(42) }
    end

    it 'does not mutate the given IBAN' do
      iban = 'de89 3704 0044 0532 0130 00'

      described_class.new(iban: iban).normalize

      expect(iban).to eq('de89 3704 0044 0532 0130 00')
    end
  end

  describe '.normalize' do
    it 'normalizes without building an instance first' do
      expect(described_class.normalize(' de89 3704 0044 0532 0130 00 ')).to eq('DE89370400440532013000')
    end
  end
end
