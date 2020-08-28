RSpec.describe NxtSupport::EnumCollection do
  subject do
    described_class['Nils Sommer', 'Rapha BIG Dog', 'Lütfi']
  end

  it do
    expect(subject.to_h).to eq(
      'nils_sommer' => 'Nils Sommer',
      'rapha_big_dog' => 'Rapha BIG Dog',
      'lütfi' => 'Lütfi'
    )
  end

  context 'when the key does not exist' do
    it do
      expect {
        subject['andy']
      }.to raise_error KeyError, /No value for key 'andy' in.*/
    end
  end

  context 'getter' do
    it do
      expect(subject.nils_sommer).to eq('Nils Sommer')
      expect(subject.rapha_big_dog).to eq('Rapha BIG Dog')
      expect(subject.lütfi).to eq('Lütfi')
    end
  end
end
