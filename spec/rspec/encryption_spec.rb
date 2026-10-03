RSpec.describe NxtSupport::RSpec::Encryption do
  let(:encryptor) { ActiveRecord::Encryption.encryptor }
  let(:envelope) { encryptor.encrypt('DE89370400440532013000') }

  def failure_of
    yield
    raise 'expected the expectation to fail'
  rescue RSpec::Expectations::ExpectationNotMetError => error
    error.message
  end

  describe '#raw_column_value' do
    let!(:db_schema) do
      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :raw_values, force: true do |t|
          t.text :payload
        end
      end
    end

    let(:record_class) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'raw_values'

        attribute :payload, NxtSupport::IndifferentJsonType.new
      end
    end

    it 'returns the value as stored in the database' do
      record = record_class.create!(payload: { key: 'value' })

      expect(raw_column_value(record, :payload)).to eq('{"key":"value"}')
    end

    it 'returns nil for an empty column' do
      record = record_class.create!

      expect(raw_column_value(record, :payload)).to be_nil
    end
  end

  describe '#be_encrypted' do
    it 'passes for an encryption envelope' do
      expect(envelope).to be_encrypted
    end

    it 'fails for plaintext' do
      message = failure_of { expect('DE89370400440532013000').to be_encrypted }

      expect(message).to eq('expected "DE89370400440532013000" to be an Active Record encryption envelope')
    end

    it 'fails for a json document that is not an envelope' do
      expect('{"iban":"DE89370400440532013000"}').not_to be_encrypted
    end

    it 'fails for nil' do
      expect(nil).not_to be_encrypted
    end

    it 'fails when negated for an envelope' do
      message = failure_of { expect(envelope).not_to be_encrypted }

      expect(message).to eq("expected #{envelope.inspect} not to be an Active Record encryption envelope")
    end
  end

  describe '#be_encrypted_at' do
    let(:document) { { iban: envelope, account_holder_first_name: 'John', accounts: [{ iban: envelope }, { iban: 'plain' }] } }
    let(:json) { document.to_json }

    it 'passes when every leaf at the path is an envelope' do
      expect(json).to be_encrypted_at('$.iban')
      expect(json).to be_encrypted_at('$.accounts[0].iban')
    end

    it 'accepts an already parsed document' do
      expect(document).to be_encrypted_at('$.iban')
    end

    it 'passes when negated and every leaf at the path is plaintext' do
      expect(json).not_to be_encrypted_at('$.account_holder_first_name')
      expect(json).not_to be_encrypted_at('$.accounts[1].iban')
    end

    it 'fails when a leaf at the path is plaintext' do
      message = failure_of { expect(json).to be_encrypted_at('$.account_holder_first_name') }

      expect(message).to eq('expected every leaf at $.account_holder_first_name to be an Active Record encryption envelope, but found ["John"]')
    end

    it 'fails when negated and a leaf at the path is an envelope' do
      message = failure_of { expect(json).not_to be_encrypted_at('$.iban') }

      expect(message).to eq("expected no leaf at $.iban to be an Active Record encryption envelope, but found [#{envelope.inspect}]")
    end

    it 'fails in both directions when a wildcard path matches encrypted and plaintext leaves' do
      expect(failure_of { expect(json).to be_encrypted_at('$.accounts[*].iban') }).to include('but found ["plain"]')
      expect(failure_of { expect(json).not_to be_encrypted_at('$.accounts[*].iban') }).to include("but found [#{envelope.inspect}]")
    end

    it 'fails in both directions when the path matches nothing' do
      expect(failure_of { expect(json).to be_encrypted_at('$.missing') })
        .to eq("expected $.missing to match at least one leaf in #{json.inspect}, but it matched none")
      expect(failure_of { expect(json).not_to be_encrypted_at('$.missing') })
        .to eq("expected $.missing to match at least one leaf in #{json.inspect}, but it matched none")
    end

    it 'fails for a whole column envelope because it holds none of the original keys' do
      expect(failure_of { expect(envelope).to be_encrypted_at('$.iban') }).to include('but it matched none')
    end

    it 'fails for a value that is not json' do
      message = failure_of { expect('not json').to be_encrypted_at('$.iban') }

      expect(message).to start_with('expected "not json" to be a JSON document, but it could not be parsed:')
    end
  end
end
