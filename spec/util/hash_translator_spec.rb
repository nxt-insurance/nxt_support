RSpec.describe NxtSupport::HashTranslator do
  subject do
    class TestClass
      include NxtSupport::HashTranslator
    end

    TestClass.translate_hash(hash, tuples)
  end

  let(:hash) do
    {
      firstname: 'Lebowsky',
      phonenumber: '8-800-555-35-35',
      havenoideakey: 'Ideas?'
    }
  end

  let(:tuples) do
    {
      firstname: :first_name,
      phonenumber: { phone_number: ->(phone){ 'Mobile: ' + phone.to_s } },
      havenoideakey: %i[why_anyone needs_same_value but_array_of_keys? will_ask]
    }
  end

  context 'happy path' do
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
end
