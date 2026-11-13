RSpec.describe NxtSupport::IndifferentJsonType do
  subject(:type) { described_class.new }

  describe '#deserialize' do
    it 'returns a HashWithIndifferentAccess for a json object' do
      result = type.deserialize('{"iban":"DE89370400440532013000"}')

      expect(result).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(result[:iban]).to eq('DE89370400440532013000')
    end

    it 'converts hashes inside arrays' do
      result = type.deserialize('[{"key":"value"}]')

      expect(result.first).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(result.first[:key]).to eq('value')
    end

    it 'decodes a legacy double encoded json string literal' do
      result = type.deserialize('"{\"iban\":\"DE89370400440532013000\"}"')

      expect(result).to eq('iban' => 'DE89370400440532013000')
      expect(result).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end

    it 'returns nil for nil' do
      expect(type.deserialize(nil)).to be_nil
    end

    it 'raises for a json scalar that is not a hash or array' do
      expect { type.deserialize('"invalid value"') }.to raise_error(ArgumentError, "Cant deserialize 'invalid value'")
    end

    it 'raises for a json string literal that looks like an object but is not valid json' do
      expect { type.deserialize('"{not json"') }.to raise_error(ArgumentError, "Cant deserialize '{not json'")
    end
  end

  describe '#cast' do
    it 'returns a HashWithIndifferentAccess for a hash' do
      expect(type.cast({ key: 'value' })).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end

    it 'returns nil for nil' do
      expect(type.cast(nil)).to be_nil
    end

    it 'raises for anything that is not a hash, array or nil' do
      expect { type.cast('invalid value') }.to raise_error(ArgumentError, "Cant deserialize 'invalid value'")
    end
  end

  describe '#serialize' do
    it 'encodes the value once' do
      expect(type.serialize({ 'key' => 'value' }.with_indifferent_access)).to eq('{"key":"value"}')
    end
  end

  describe '#changed_in_place?' do
    it 'detects a changed hash' do
      expect(type.changed_in_place?('{"key":"value"}', { 'key' => 'other' }.with_indifferent_access)).to be(true)
    end

    it 'treats an equal hash as unchanged' do
      expect(type.changed_in_place?('{"key":"value"}', { 'key' => 'value' }.with_indifferent_access)).to be(false)
    end
  end
end
