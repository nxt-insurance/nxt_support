RSpec.describe NxtSupport::BirthDate do
  let(:now) { Time.parse('2020-09-09') }

  around(:each) do |example|
    travel_to(now) { example.run }
  end

  context 'when the date is a string' do
    subject do
      described_class.new(date: '1990-08-08')
    end

    it 'returns the age in years' do
      expect(subject.to_age).to eq(30)
    end

    it 'returns the age in months' do
      expect(subject.to_age_in_months).to eq(361)
    end
  end

  context 'when the date is a date' do
    subject do
      described_class.new(date: 30.years.ago.to_date)
    end

    it 'returns the age in years' do
      expect(subject.to_age).to eq(30)
    end

    it 'returns the age in months' do
      expect(subject.to_age_in_months).to eq(360)
    end
  end
end
