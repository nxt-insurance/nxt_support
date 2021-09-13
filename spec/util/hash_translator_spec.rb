RSpec.describe NxtSupport::HashTranslator do
  subject do
    class TestClass
      include NxtSupport::HashTranslator
    end

    TestClass.new.translate_hash(hash, **tuples)
  end

  let(:hash) do
    {
      firstname: 'Lebowsky',
      phonenumber: '8-800-555-35-35',
      havenoideakey: 'Ideas?'
    }
  end

  context 'happy path' do
    let(:tuples) do
      {
        firstname: :first_name,
        phonenumber: { phone_number: ->(phone){ 'Mobile: ' + phone.to_s } },
        havenoideakey: %i[why_anyone needs_same_value but_array_of_keys? will_ask]
      }
    end

    it do
      expect(subject).to eq(
        'first_name' => 'Lebowsky',
        'phone_number' => 'Mobile: 8-800-555-35-35',
        'why_anyone' => 'Ideas?',
        'needs_same_value' => 'Ideas?',
        'but_array_of_keys?' => 'Ideas?',
        'will_ask' => 'Ideas?'
      )
    end
  end

  context 'with invalid tuple arguments' do
    context 'as a hash' do
      context 'with multiple key-value pairs' do
        let(:tuples) do
          {
            firstname: :first_name,
            phonenumber: { phone_number: ->(phone){ 'Mobile: ' + phone.to_s }, unused_key: :unused_value },
            havenoideakey: %i[why_anyone needs_same_value but_array_of_keys? will_ask]
          }
        end

        it 'raise an error' do
          expect { subject }.to raise_exception(NxtSupport::HashTranslator::HashTranslationService::InvalidTranslationArgument)
            .with_message(/must contain only 1 key-value pair!/)
        end
      end

      context 'with uncallable block' do
        let(:tuples) do
          {
            firstname: :first_name,
            phonenumber: { phone_number: :uncallable_block },
            havenoideakey: %i[why_anyone needs_same_value but_array_of_keys? will_ask]
          }
        end

        it 'raise an error' do
          expect { subject }.to raise_exception(NxtSupport::HashTranslator::HashTranslationService::InvalidTranslationArgument)
            .with_message('uncallable_block must be a callable block!')
        end
      end
    end
  end
end
