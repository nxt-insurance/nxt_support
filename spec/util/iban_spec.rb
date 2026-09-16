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

  describe '#to_s' do
    subject { described_class.new(iban: iban).to_s }

    context 'when the IBAN is a string' do
      let(:iban) { ' de89 3704 0044 0532 0130 00 ' }

      it { is_expected.to eq('DE89370400440532013000') }
    end

    context 'when the IBAN is nil' do
      let(:iban) { nil }

      it { is_expected.to eq('') }
    end

    it 'is used for string interpolation' do
      expect("IBAN: #{described_class.new(iban: 'de89 3704 0044 0532 0130 00')}").to eq('IBAN: DE89370400440532013000')
    end
  end

  describe '#country_code' do
    subject { described_class.new(iban: iban).country_code }

    context 'when the IBAN is written with lower-case letters and whitespace' do
      let(:iban) { ' de89 3704 0044 0532 0130 00 ' }

      it { is_expected.to eq('DE') }
    end

    context 'when the IBAN is from another country' do
      let(:iban) { 'GB33BUKB20201555555555' }

      it { is_expected.to eq('GB') }
    end

    context 'when the IBAN is shorter than the country code' do
      let(:iban) { 'D' }

      it { is_expected.to eq('D') }
    end

    context 'when the IBAN is nil' do
      let(:iban) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the IBAN is an empty string' do
      let(:iban) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '#last4' do
    subject { described_class.new(iban: iban).last4 }

    context 'when the IBAN is written with whitespace' do
      let(:iban) { 'DE89 3704 0044 0532 0130 00' }

      it { is_expected.to eq('3000') }
    end

    context 'when the IBAN is written with lower-case letters' do
      let(:iban) { 'de89370400440532013000' }

      it { is_expected.to eq('3000') }
    end

    context 'when the IBAN is shorter than four characters' do
      let(:iban) { 'DE8' }

      it { is_expected.to eq('DE8') }
    end

    context 'when the IBAN is nil' do
      let(:iban) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the IBAN is an empty string' do
      let(:iban) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '.normalize' do
    it 'normalizes without building an instance first' do
      expect(described_class.normalize(' de89 3704 0044 0532 0130 00 ')).to eq('DE89370400440532013000')
    end
  end
end
