RSpec.describe NxtSupport::EncryptedJsonPathsType do
  subject(:type) { described_class.new(*paths, deterministic: deterministic) }

  let(:paths) { %w[$.iban] }
  let(:deterministic) { false }
  let(:iban) { 'DE89370400440532013000' }

  def stored_leaf(serialized, *keys)
    JSON.parse(serialized).dig(*keys)
  end

  describe '#serialize' do
    it 'encrypts the configured leaf and leaves the rest untouched' do
      serialized = type.serialize({ iban: iban, account_holder_first_name: 'John' })

      expect(serialized).to be_encrypted_at('$.iban')
      expect(serialized).not_to include(iban)
      expect(stored_leaf(serialized, 'account_holder_first_name')).to eq('John')
    end

    it 'encrypts leaves given with string keys' do
      expect(type.serialize({ 'iban' => iban })).to be_encrypted_at('$.iban')
    end

    it 'encrypts leaves given with symbol keys' do
      expect(type.serialize({ iban: iban })).to be_encrypted_at('$.iban')
    end

    it 'does not mutate the given value' do
      value = { iban: iban }.with_indifferent_access
      type.serialize(value)

      expect(value[:iban]).to eq(iban)
    end

    it 'does not touch a missing path' do
      expect(type.serialize({ other: 'value' })).to eq('{"other":"value"}')
    end

    it 'does not encrypt non string leaves' do
      expect(type.serialize({ iban: 123 })).to eq('{"iban":123}')
    end

    it 'does not encrypt an already encrypted leaf twice' do
      once = stored_leaf(type.serialize({ iban: iban }), 'iban')
      twice = stored_leaf(type.serialize({ iban: once }), 'iban')

      expect(twice).to eq(once)
    end

    it 'returns nil for nil' do
      expect(type.serialize(nil)).to be_nil
    end

    context 'with nested and array paths' do
      let(:paths) { %w[$.payment.bank_data.iban $.accounts[*].iban] }

      it 'encrypts leaves inside nested hashes and inside arrays' do
        serialized = type.serialize(
          { payment: { bank_data: { iban: iban, bic: 'COBADEFF' } }, accounts: [{ iban: iban }, { iban: nil }] }
        )

        expect(serialized).to be_encrypted_at('$.payment.bank_data.iban')
        expect(serialized).not_to be_encrypted_at('$.payment.bank_data.bic')
        expect(serialized).to be_encrypted_at('$.accounts[0].iban')
        expect(stored_leaf(serialized, 'accounts', 1, 'iban')).to be_nil
      end
    end

    context 'with a recursive descent path' do
      let(:paths) { %w[$..iban] }

      it 'encrypts every leaf with that key at any depth' do
        serialized = type.serialize({ iban: iban, payment: { bank_data: { iban: iban } }, accounts: [{ iban: iban }] })

        expect(serialized).to be_encrypted_at('$..iban')
      end
    end

    context 'with a filter expression' do
      let(:paths) { ["$.accounts[?(@.type == 'sepa')].iban"] }

      it 'encrypts only the matching elements' do
        serialized = type.serialize({ accounts: [{ type: 'sepa', iban: iban }, { type: 'paypal', iban: 'not-an-iban' }] })

        expect(serialized).to be_encrypted_at('$.accounts[0].iban')
        expect(stored_leaf(serialized, 'accounts', 1, 'iban')).to eq('not-an-iban')
      end
    end

    context 'when encryption is disabled' do
      it 'stores the plaintext leaf' do
        serialized = ActiveRecord::Encryption.without_encryption { type.serialize({ iban: iban }) }

        expect(stored_leaf(serialized, 'iban')).to eq(iban)
      end
    end
  end

  describe '#deserialize' do
    it 'round trips to an indifferently accessible hash with the plaintext leaf' do
      result = type.deserialize(type.serialize({ iban: iban, account_holder_first_name: 'John' }))

      expect(result).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(result[:iban]).to eq(iban)
      expect(result['account_holder_first_name']).to eq('John')
    end

    it 'passes through a plaintext leaf' do
      expect(type.deserialize('{"iban":"DE89370400440532013000"}')[:iban]).to eq(iban)
    end

    it 'reads a legacy double encoded json string literal' do
      expect(type.deserialize('"{\"iban\":\"DE89370400440532013000\"}"')[:iban]).to eq(iban)
    end

    it 'returns nil for nil' do
      expect(type.deserialize(nil)).to be_nil
    end
  end

  describe '#changed_in_place?' do
    it 'compares the decrypted value' do
      serialized = type.serialize({ iban: iban })

      expect(type.changed_in_place?(serialized, { 'iban' => iban }.with_indifferent_access)).to be(false)
      expect(type.changed_in_place?(serialized, { 'iban' => 'DE02120300000000202051' }.with_indifferent_access)).to be(true)
    end
  end

  describe '#encrypt_for_query' do
    context 'when deterministic' do
      let(:deterministic) { true }

      it 'returns the same ciphertext that is stored for the leaf' do
        expect(type.encrypt_for_query(iban)).to eq(stored_leaf(type.serialize({ iban: iban }), 'iban'))
      end
    end

    context 'when not deterministic' do
      it 'produces different ciphertexts for the same value' do
        first = stored_leaf(type.serialize({ iban: iban }), 'iban')
        second = stored_leaf(type.serialize({ iban: iban }), 'iban')

        expect(first).not_to eq(second)
      end

      it 'raises because a non deterministic ciphertext cannot be queried' do
        expect { type.encrypt_for_query(iban) }.to raise_error(ArgumentError, 'querying encrypted fields requires deterministic: true')
      end
    end
  end
end
