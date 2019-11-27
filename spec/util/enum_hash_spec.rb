RSpec.describe NxtSupport::EnumHash do
  subject do
    described_class['Nils Sommer', 'Rapha BIG Dog', 'Lütfi']
  end

  context 'when the key exists' do
    it do
      expect(subject).to eq(
        'nils_sommer' => 'Nils Sommer',
        'rapha_big_dog' => 'Rapha BIG Dog',
        'lütfi' => 'Lütfi'
      )
    end
  end

  context 'when the key does not exist' do
    it do
      expect {
        subject['andy']
      }.to raise_error KeyError, /No value for key 'andy' in.*/
    end
  end
end
