RSpec.describe NxtSupport::EncryptedJsonAttrs do
  let(:iban) { 'DE89370400440532013000' }
  let(:encryptor) { ActiveRecord::Encryption.encryptor }
  let(:connection) { ActiveRecord::Base.connection }

  let!(:db_schema) do
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :encrypted_documents, force: true do |t|
        t.text :data
      end

      create_table :encrypted_payment_methods, force: true do |t|
        t.json :data
      end
    end
  end

  def raw_column(sql, id)
    connection.select_value(ActiveRecord::Base.sanitize_sql_array([sql, id]))
  end

  def update_raw_column(table, value, id)
    connection.execute(ActiveRecord::Base.sanitize_sql_array(["UPDATE #{table} SET data = ? WHERE id = ?", value, id]))
  end

  describe '.encrypts_json_entirely' do
    let(:document_class) do
      Class.new(ActiveRecord::Base) do
        include NxtSupport::EncryptedJsonAttrs

        self.table_name = 'encrypted_documents'

        encrypts_json_entirely :data
      end
    end

    let(:document) { document_class.create!(data: { payment: { bank_data: { iban: iban } } }) }

    it 'stores the whole column as an encrypted envelope' do
      raw = raw_column('SELECT data FROM encrypted_documents WHERE id = ?', document.id)

      expect(encryptor.encrypted?(raw)).to be(true)
      expect(raw).not_to include(iban)
    end

    it 'reads the column back as an indifferently accessible hash' do
      data = document.reload.data

      expect(data).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(data.dig(:payment, :bank_data, :iban)).to eq(iban)
      expect(data.dig('payment', 'bank_data', 'iban')).to eq(iban)
    end

    it 'persists in place mutations' do
      document.data.deep_merge!(payment: { bank_data: { bic: 'COBADEFF' } })
      document.save!

      expect(document.reload.data.dig(:payment, :bank_data, :bic)).to eq('COBADEFF')
    end

    it 'does not mark an unchanged record as changed' do
      expect(document.reload).not_to be_changed
    end

    it 'defaults to an empty indifferently accessible hash' do
      expect(document_class.new.data).to eq({})
      expect(document_class.new.data).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end

    it 'passes encryption options on to encrypts' do
      deterministic_class = Class.new(ActiveRecord::Base) do
        include NxtSupport::EncryptedJsonAttrs

        self.table_name = 'encrypted_documents'

        encrypts_json_entirely :data, deterministic: true
      end

      expect(deterministic_class.type_for_attribute('data')).to be_deterministic
    end

    context 'when unencrypted data is supported' do
      around do |example|
        ActiveRecord::Encryption.config.support_unencrypted_data = true
        example.run
      ensure
        ActiveRecord::Encryption.config.support_unencrypted_data = false
      end

      it 'reads legacy plaintext rows' do
        update_raw_column('encrypted_documents', { iban: iban }.to_json, document.id)

        expect(document.reload.data[:iban]).to eq(iban)
      end

      it 'reads legacy double encoded rows written by indifferently_accessible_json_attrs' do
        update_raw_column('encrypted_documents', { iban: iban }.to_json.to_json, document.id)

        expect(document.reload.data[:iban]).to eq(iban)
      end
    end
  end

  describe '.encrypts_json_attrs' do
    let(:payment_method_class) do
      Class.new(ActiveRecord::Base) do
        include NxtSupport::EncryptedJsonAttrs

        self.table_name = 'encrypted_payment_methods'

        encrypts_json_attrs column: :data, paths: %w[iban], deterministic: true
      end
    end

    let(:payment_method) { payment_method_class.create!(data: { iban: iban, account_holder_first_name: 'John' }) }

    it 'stores only the configured field encrypted' do
      raw_iban = raw_column("SELECT json_extract(data, '$.iban') FROM encrypted_payment_methods WHERE id = ?", payment_method.id)
      raw_first_name = raw_column(
        "SELECT json_extract(data, '$.account_holder_first_name') FROM encrypted_payment_methods WHERE id = ?", payment_method.id
      )

      expect(encryptor.encrypted?(raw_iban)).to be(true)
      expect(raw_iban).not_to include(iban)
      expect(raw_first_name).to eq('John')
    end

    it 'reads the field back decrypted' do
      data = payment_method.reload.data

      expect(data).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(data[:iban]).to eq(iban)
      expect(data['account_holder_first_name']).to eq('John')
    end

    it 'persists in place mutations' do
      payment_method.data[:iban] = 'DE02120300000000202051'
      payment_method.save!

      expect(payment_method.reload.data[:iban]).to eq('DE02120300000000202051')
    end

    it 'does not mark an unchanged record as changed' do
      expect(payment_method.reload).not_to be_changed
    end

    it 'defaults to an empty indifferently accessible hash' do
      expect(payment_method_class.new.data).to eq({})
      expect(payment_method_class.new.data).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end

    it 'reads legacy plaintext rows' do
      update_raw_column('encrypted_payment_methods', { iban: iban }.to_json, payment_method.id)

      expect(payment_method.reload.data[:iban]).to eq(iban)
    end

    it 'reads legacy double encoded rows written by indifferently_accessible_json_attrs' do
      update_raw_column('encrypted_payment_methods', { iban: iban }.to_json.to_json, payment_method.id)

      expect(payment_method.reload.data[:iban]).to eq(iban)
    end

    describe '.encrypted_json_value_for' do
      it 'returns the ciphertext that is stored for the field' do
        raw_iban = raw_column("SELECT json_extract(data, '$.iban') FROM encrypted_payment_methods WHERE id = ?", payment_method.id)

        expect(payment_method_class.encrypted_json_value_for(:data, iban)).to eq(raw_iban)
      end
    end

    describe '.where_encrypted_json' do
      subject(:sql) { payment_method_class.where_encrypted_json(:data, path: path, value: iban).to_sql }

      let(:path) { 'iban' }

      it 'matches the deterministic ciphertext at the json path' do
        expect(sql).to include(%(jsonb_path_query("encrypted_payment_methods"."data", '$.iban')))
        expect(sql).to include("#>> '{}' = '#{payment_method_class.encrypted_json_value_for(:data, iban)}'")
      end

      context 'with a json path' do
        let(:path) { '$.accounts[*].iban' }

        it 'passes it through' do
          expect(sql).to include("'$.accounts[*].iban'")
        end
      end

      context 'with a recursive descent path' do
        let(:path) { '$..iban' }

        it 'translates it into the PostgreSQL jsonpath syntax' do
          expect(sql).to include("'$.**.iban'")
        end
      end

      context 'when the field is not deterministic' do
        let(:payment_method_class) do
          Class.new(ActiveRecord::Base) do
            include NxtSupport::EncryptedJsonAttrs

            self.table_name = 'encrypted_payment_methods'

            encrypts_json_attrs column: :data, paths: %w[iban]
          end
        end

        it 'raises' do
          expect { sql }.to raise_error(ArgumentError, 'querying encrypted fields requires deterministic: true')
        end
      end
    end
  end
end
